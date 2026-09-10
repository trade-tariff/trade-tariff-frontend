require 'spec_helper'

RSpec.describe 'Browser session logging', :aggregate_failures, type: :request do
  let(:request_events) { [] }
  let(:journey_events) { [] }

  around do |example|
    request_subscriber = ActiveSupport::Notifications.subscribe('process_action.action_controller') do |*args|
      request_events << ActiveSupport::Notifications::Event.new(*args).payload
    end
    journey_subscriber = ActiveSupport::Notifications.subscribe('guided_search.journey') do |*args|
      journey_events << ActiveSupport::Notifications::Event.new(*args).payload
    end
    example.run
  ensure
    ActiveSupport::Notifications.unsubscribe(request_subscriber)
    ActiveSupport::Notifications.unsubscribe(journey_subscriber)
  end

  it 'correlates visits across pages' do
    get privacy_path
    get help_path

    expect(response).to have_http_status(:ok)
    expect(request_events.pluck(:browser_session_id).uniq).to contain_exactly(
      a_string_matching(/\Av1:[0-9a-f]{64}\z/),
    )
    expect(request_events.pluck(:request_id).uniq.size).to eq(2)
  end

  it 'renews the ID for a new session' do
    get privacy_path
    cookies.delete('_tradetarifffrontend_session')
    get privacy_path

    identifiers = request_events.pluck(:browser_session_id)
    expect(identifiers).to all(match(/\Av1:[0-9a-f]{64}\z/))
    expect(identifiers.uniq.size).to eq(2)
  end

  it 'does not expose the session value' do
    get privacy_path

    raw_id = request.session[:guided_search_browser_session_id]
    expect(raw_id).to be_present
    expect(request_events.last[:browser_session_id]).to eq(
      "v1:#{OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secret_key_base, raw_id)}",
    )
    expect(request_events.last[:browser_session_id]).not_to include(raw_id)
  end

  it 'shares the guided-search identifier' do
    post guided_search_event_path,
         params: { event_type: 'dont_know', request_id: 'search-123', question_number: 1, client_elapsed_ms: 100 },
         as: :json
    get privacy_path

    expect(request_events.pluck(:browser_session_id).uniq).to eq(journey_events.pluck(:browser_session_id))
    expect(journey_events.last[:request_id]).to eq('search-123')
  end

  context 'when pseudonymisation fails' do
    before do
      allow(GuidedSearch::JourneyInstrumentation).to receive(:browser_session_id).and_raise(StandardError)
    end

    it 'still serves the page' do
      get privacy_path

      expect(response).to have_http_status(:ok)
      expect(request_events.last[:browser_session_id]).to be_nil
    end
  end
end
