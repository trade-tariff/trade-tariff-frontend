require 'spec_helper'

RSpec.describe 'Guided search journey events', :aggregate_failures, type: :request do
  let(:journey_events) { [] }

  around do |example|
    subscriber = ActiveSupport::Notifications.subscribe('guided_search.journey') do |*args|
      journey_events << ActiveSupport::Notifications::Event.new(*args).payload
    end
    example.run
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  it 'records each supported browser event' do
    cases = [
      [
        { event_type: 'dont_know', request_id: 123, question_number: 2, client_elapsed_ms: 4_321, question_id: 'question-123', event_id: 'event-123' },
        {
          outcome: 'dont_know',
          used_dont_know: true,
          request_id: '123',
          question_count: 2,
          client_elapsed_ms: 4_321,
          question_response: 'dont_know',
          terminal_outcome: 'dont_know',
          question_id: 'question-123',
          event_id: 'event-123',
        },
      ],
      [
        {
          event_type: 'result_selected',
          request_id: 'request-123',
          goods_nomenclature_item_id: '2007919930',
          result_rank: 2,
          confidence: 'Good',
          client_elapsed_ms: 4_200,
        },
        {
          outcome: 'result_selected',
          request_id: 'request-123',
          goods_nomenclature_item_id: '2007919930',
          result_rank: 2,
          confidence: 'good',
          client_elapsed_ms: 4_200,
        },
      ],
      [
        {
          event_type: 'start_again',
          request_id: 'request-123',
          destination: 'results',
          client_elapsed_ms: 3_100,
        },
        {
          outcome: 'start_again',
          request_id: 'request-123',
          destination: 'results',
          client_elapsed_ms: 3_100,
        },
      ],
      [
        { event_type: 'page_visible', request_id: 'request-123', destination: 'question', client_navigation_ms: 1_234 },
        { outcome: 'page_visible', request_id: 'request-123', destination: 'question', client_navigation_ms: 1_234 },
      ],
    ]

    cases.each do |params, expected|
      post guided_search_event_path, params:, as: :json

      expect(response).to have_http_status(:no_content)
      expect(journey_events.shift).to include(expected)
    end
    expect(journey_events).to be_empty
  end

  it 'records a visible page without navigation timing' do
    post guided_search_event_path,
         params: { event_type: 'page_visible', request_id: 'request-123', destination: 'results' },
         as: :json

    expect(response).to have_http_status(:no_content)
    expect(journey_events.sole).to include(outcome: 'page_visible', destination: 'results', request_id: 'request-123')
    expect(journey_events.sole).not_to have_key(:client_navigation_ms)
  end

  it 'rejects malformed navigation timing' do
    post guided_search_event_path,
         params: { event_type: 'page_visible', request_id: 'request-123', destination: 'results', client_navigation_ms: 'invalid' },
         as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(journey_events).to be_empty
  end

  it 'uses one pseudonymous identifier for the browser session' do
    2.times do |index|
      post guided_search_event_path,
           params: { event_type: 'dont_know', request_id: "request-#{index}", question_number: 1, client_elapsed_ms: 100 },
           as: :json
    end

    expect(journey_events.pluck(:browser_session_id).uniq).to contain_exactly(
      a_string_matching(/\Av1:[0-9a-f]{64}\z/),
    )
  end

  it 'rejects incomplete events without recording them' do
    post guided_search_event_path,
         params: { event_type: 'page_visible', request_id: 'request-123', destination: 'invented' },
         as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(journey_events).to be_empty
  end

  it 'records a browser initial submit with its request id and no query text' do
    post guided_search_event_path,
         params: {
           event_type: 'initial_submitted',
           request_id: 'request-123',
           submission_id: 'submission-123',
           event_id: 'event-123',
           q: 'private query',
           service: 'xi',
           search_scope: 'classic',
         },
         as: :json

    expect(response).to have_http_status(:no_content)
    expect(journey_events.sole).to include(
      outcome: 'initial_submitted',
      submission_source: 'browser',
      schema_version: 1,
      service: 'uk',
      search_scope: 'guided',
      request_id: 'request-123',
      submission_id: 'submission-123',
      event_id: 'event-123',
    )
    expect(journey_events.to_json).not_to include('private query')
  end

  it 'records a browser-selected answer separately from dont_know' do
    post guided_search_event_path,
         params: {
           event_type: 'answer_submitted',
           request_id: 'request-123',
           question_id: 'question-123',
           submission_id: 'submission-123',
           event_id: 'event-123',
           response_source: 'browser_selected',
           question_number: 2,
           answer: 'Haddock',
         },
         as: :json

    expect(response).to have_http_status(:no_content)
    expect(journey_events.sole).to include(
      outcome: 'answer_submitted',
      response_source: 'browser_selected',
      question_response: 'browser_selected',
      question_id: 'question-123',
      question_count: 2,
    )
    expect(journey_events.sole).not_to have_key(:client_elapsed_ms)
    expect(journey_events.to_json).not_to include('Haddock')
  end

  it 'rejects malformed telemetry ids and an answer without the browser source' do
    post guided_search_event_path,
         params: { event_type: 'initial_submitted', request_id: 'request-123', event_id: 'bad id' },
         as: :json
    post guided_search_event_path,
         params: {
           event_type: 'answer_submitted',
           request_id: 'request-123',
           question_id: 'question-123',
           event_id: 'event-123',
           response_source: 'accepted',
         },
         as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(journey_events).to be_empty
  end
end
