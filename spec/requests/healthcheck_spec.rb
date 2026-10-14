require 'spec_helper'

RSpec.describe 'Healthcheck routes', type: :request do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('MAINTENANCE').and_return('true')
    allow(Section).to receive(:all).and_return([])
  end

  it 'stays available during maintenance', :aggregate_failures do
    events = []

    ActiveSupport::Notifications.subscribed(
      ->(*args) { events << ActiveSupport::Notifications::Event.new(*args) },
      'process_action.action_controller',
    ) do
      get '/healthcheck'
    end

    event = events.find { |candidate| candidate.payload[:controller] == 'HealthcheckController' }

    expect(response).to have_http_status(:ok)
    expect(response).not_to be_redirect
    expect(response.parsed_body).to eq('git_sha1' => CURRENT_REVISION)
    expect(response.headers['Set-Cookie']).to be_blank
    expect(event.payload).not_to have_key(:browser_session_id)
    expect(ApplicationController.rescue_handlers.map(&:first)).to include('Faraday::ConnectionFailed')
  end

  it 'keeps the shallow check available during maintenance', :aggregate_failures do
    get '/healthcheckz'

    expect(response).to have_http_status(:ok)
    expect(response).not_to be_redirect
    expect(response.parsed_body).to eq('git_sha1' => CURRENT_REVISION)
    expect(response.headers['Set-Cookie']).to be_blank
  end
end
