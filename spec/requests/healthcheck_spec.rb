require 'spec_helper'

RSpec.describe 'Healthcheck routes', type: :request do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('MAINTENANCE').and_return('true')
  end

  describe 'GET /healthcheck' do
    it 'stays available during maintenance', :aggregate_failures do
      allow(Section).to receive(:all).and_return([])
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
      expect(response.body).not_to include('govuk-template')
      expect(response.headers['Set-Cookie']).to be_blank
      expect(event.payload).not_to have_key(:browser_session_id)
      expect(ApplicationController.rescue_handlers.map(&:first)).to include('Faraday::ConnectionFailed')
    end

    it 'returns an empty 500 when the API reports a server error', :aggregate_failures do
      allow(Section).to receive(:all).and_raise(Faraday::ServerError, 'Bad request')

      get '/healthcheck'

      expect(response).to have_http_status(:internal_server_error)
      expect(response).not_to be_redirect
      expect(response.body).to eq('')
      expect(response.headers['Location']).to be_blank
    end

    it 'returns an empty 500 when the API connection fails', :aggregate_failures do
      allow(Section).to receive(:all).and_raise(Faraday::ConnectionFailed, 'connection failed')

      get '/healthcheck'

      expect(response).to have_http_status(:internal_server_error)
      expect(response).not_to be_redirect
      expect(response.body).to eq('')
      expect(response.headers['Location']).to be_blank
      expect(response.headers['Set-Cookie']).to be_blank
    end
  end

  describe 'GET /healthcheckz' do
    it 'stays available during maintenance', :aggregate_failures do
      get '/healthcheckz'

      expect(response).to have_http_status(:ok)
      expect(response).not_to be_redirect
      expect(response.parsed_body).to eq('git_sha1' => CURRENT_REVISION)
      expect(response.body).not_to include('govuk-template')
      expect(response.headers['Set-Cookie']).to be_blank
    end
  end
end
