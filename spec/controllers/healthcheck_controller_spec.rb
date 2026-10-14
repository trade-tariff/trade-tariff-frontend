require 'spec_helper'

RSpec.describe HealthcheckController, type: :controller do
  describe '#check' do
    context 'when Section.all succeeds' do
      before do
        allow(Section).to receive(:all).and_return([])
      end

      it 'returns 200', :aggregate_failures do
        get :check

        expect(response).to have_http_status(:ok)
        expect(response).not_to be_redirect
        expect(response.parsed_body).to eq('git_sha1' => CURRENT_REVISION)
        expect(response.body).not_to include('govuk-template')
        expect(response).not_to render_template(layout: 'application')
      end
    end

    context 'when Section.all raises Faraday::ServerError' do
      before do
        allow(Section).to receive(:all)
          .and_raise(Faraday::ServerError, 'Bad request')
      end

      it 'returns 500', :aggregate_failures do
        get :check

        expect(response).to have_http_status(:internal_server_error)
        expect(response).not_to be_redirect
        expect(response.body).to eq('')
        expect(response.body).not_to include('govuk-template')
      end
    end

    context 'when Section.all raises Faraday::ConnectionFailed' do
      before do
        allow(Section).to receive(:all)
          .and_raise(Faraday::ConnectionFailed, 'connection failed')
      end

      it 'does not turn a connection failure into an application error page' do
        expect { get :check }.to raise_error(Faraday::ConnectionFailed)
      end
    end
  end

  describe '#checkz' do
    it 'returns 200', :aggregate_failures do
      get :checkz

      expect(response).to have_http_status(:ok)
      expect(response).not_to be_redirect
      expect(response.parsed_body).to eq('git_sha1' => CURRENT_REVISION)
      expect(response.body).not_to include('govuk-template')
      expect(response).not_to render_template(layout: 'application')
    end
  end
end
