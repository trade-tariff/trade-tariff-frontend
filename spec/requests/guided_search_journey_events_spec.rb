require 'spec_helper'

RSpec.describe 'Guided search journey events', type: :request do
  let(:journey_events) { [] }

  around do |example|
    subscriber = ActiveSupport::Notifications.subscribe('guided_search.journey') do |*args|
      journey_events << ActiveSupport::Notifications::Event.new(*args).payload
    end
    example.run
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  it 'records when a user selects the unknown answer', :aggregate_failures do
    post '/search/guided-search-event',
         params: {
           event_type: 'dont_know',
           request_id: 'request-123',
           question_number: 2,
           client_elapsed_ms: 4_321,
         },
         as: :json

    expect(response).to have_http_status(:no_content)
    expect(journey_events).to contain_exactly(
      hash_including(
        outcome: 'dont_know',
        used_dont_know: true,
        request_id: 'request-123',
        question_count: 2,
        client_elapsed_ms: 4_321,
        browser_session_id: a_string_starting_with('v1:'),
      ),
    )
  end

  it 'records the displayed result selected by the user', :aggregate_failures do
    post '/search/guided-search-event',
         params: {
           event_type: 'result_selected',
           request_id: 'request-123',
           goods_nomenclature_item_id: '2007919930',
           result_rank: 2,
           confidence: 'good',
         },
         as: :json

    expect(response).to have_http_status(:no_content)
    expect(journey_events).to contain_exactly(
      hash_including(
        outcome: 'result_selected',
        request_id: 'request-123',
        goods_nomenclature_item_id: '2007919930',
        result_rank: 2,
        confidence: 'good',
        browser_session_id: a_string_starting_with('v1:'),
      ),
    )
  end

  it 'records the destination and browser-visible navigation time', :aggregate_failures do
    post '/search/guided-search-event',
         params: {
           event_type: 'page_visible',
           request_id: 'request-123',
           destination: 'question',
           client_navigation_ms: 1_234,
         },
         as: :json

    expect(response).to have_http_status(:no_content)
    expect(journey_events).to contain_exactly(
      hash_including(
        outcome: 'page_visible',
        destination: 'question',
        request_id: 'request-123',
        client_navigation_ms: 1_234,
      ),
    )
  end

  it 'uses one pseudonymous identifier for the browser session' do
    2.times do |index|
      post '/search/guided-search-event',
           params: {
             event_type: 'dont_know',
             request_id: "request-#{index}",
             question_number: 1,
             client_elapsed_ms: 100,
           },
           as: :json
    end

    expect(journey_events.pluck(:browser_session_id).uniq).to contain_exactly(
      a_string_matching(/\Av1:[0-9a-f]{64}\z/),
    )
  end

  it 'rejects incomplete events without recording them', :aggregate_failures do
    post '/search/guided-search-event',
         params: {
           event_type: 'page_visible',
           request_id: 'request-123',
           destination: 'invented',
         },
         as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(journey_events).to be_empty
  end
end
