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

  describe 'classifier click forwarding' do
    let(:click) do
      { event_type: 'result_selected', request_id: 'request-123', goods_nomenclature_item_id: '2007919930', result_rank: 2, confidence: 'Good' }
    end
    let!(:backend_request) do
      stub_api_request('/search_export/result_clicks', :post, internal: true).to_return(status: 204)
    end

    it 'sends only the request id, code and rank to the backend' do
      post guided_search_event_path, params: click, as: :json

      expect(response).to have_http_status(:no_content)
      expect(backend_request.with(body: { request_id: 'request-123', goods_nomenclature_item_id: '2007919930', result_rank: 2 }.to_json)).to have_been_requested.once
    end

    it 'bounds capture timeouts without changing the shared client defaults' do
      client = TradeTariffFrontend::ServiceChooser.api_client
      original_timeout = client.options.timeout
      allow(client).to receive(:post).and_wrap_original do |original, *arguments, &configure|
        original.call(*arguments) do |request|
          configure.call(request)
          expect(request.options.timeout).to eq(2)
          expect(request.options.open_timeout).to eq(1)
        end
      end

      post guided_search_event_path, params: click, as: :json

      expect(backend_request).to have_been_requested.once
      expect(client.options.timeout).to eq(original_timeout)
    end

    it 'keeps recording the browser event when the backend times out' do
      backend_request.to_timeout

      post guided_search_event_path, params: click, as: :json

      expect(response).to have_http_status(:no_content)
      expect(backend_request).to have_been_requested.once
      expect(journey_events.last).to include(outcome: 'result_selected')
    end

    it 'does not send non-click events to the backend' do
      post guided_search_event_path, params: { event_type: 'dont_know', request_id: 'request-123', question_number: 1 }, as: :json

      expect(backend_request).not_to have_been_requested
    end

    it 'does not forward clicks in XI' do
      allow(TradeTariffFrontend::ServiceChooser).to receive(:xi?).and_return(true)

      post guided_search_event_path, params: click, as: :json

      expect(response).to have_http_status(:no_content)
      expect(backend_request).not_to have_been_requested
    end
  end

  it 'rejects incomplete events without recording them' do
    post guided_search_event_path,
         params: { event_type: 'page_visible', request_id: 'request-123', destination: 'invented' },
         as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(journey_events).to be_empty
  end
end
