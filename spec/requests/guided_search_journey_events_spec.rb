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
        { event_type: 'dont_know', request_id: 123, question_number: 2, client_elapsed_ms: 4_321 },
        { outcome: 'dont_know', used_dont_know: true, request_id: '123', question_count: 2, client_elapsed_ms: 4_321 },
      ],
      [
        {
          event_type: 'result_selected',
          request_id: 'request-123',
          goods_nomenclature_item_id: '2007919930',
          result_rank: 2,
          confidence: 'Good',
        },
        {
          outcome: 'result_selected',
          request_id: 'request-123',
          goods_nomenclature_item_id: '2007919930',
          result_rank: 2,
          confidence: 'good',
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
end
