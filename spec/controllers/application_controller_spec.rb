require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'Hari Seldon'
    end
  end

  describe 'GET #index' do
    subject(:response) { get :index }

    let(:expected_cache_control) do
      %w[
        max-age=0
        public
        must-revalidate
        proxy-revalidate
      ].join(', ')
    end

    it { expect(response.headers['Cache-Control']).to eq(expected_cache_control) }
    it { expect(response.headers['Pragma']).to eq('no-cache') }
    it { expect(response.headers['Expires']).to eq('-1') }
  end

  describe 'identity resolution' do
    # CurrentAttributes are reset after each request, so we capture the identity
    # during the request by rendering it in the action response body.
    controller do
      def index
        render plain: Current.flagsmith_identity.class.name
      end
    end

    context 'with no JWT cookie' do
      it 'sets an anonymous identity on Current' do
        get :index
        expect(response.body).to eq('Flagsmith::AnonymousIdentity')
      end

      it 'stores the anonymous UUID in a cookie' do
        get :index
        expect(cookies[:flipper_anonymous_id]).to be_present
      end
    end

    context 'with a valid JWT cookie containing an email claim' do
      controller do
        def index
          render plain: Current.flagsmith_identity.identifier
        end
      end

      before do
        payload = { 'email' => 'neil@example.com', 'sub' => 'sub-123' }
        token = JWT.encode(payload, nil, 'none')
        cookies[TradeTariffFrontend.id_token_cookie_name] = token
      end

      it 'sets a user identity on Current with the email as identifier' do
        get :index
        expect(response.body).to eq('User:neil@example.com')
      end
    end

    context 'with a JWT containing only a sub claim' do
      controller do
        def index
          render plain: Current.flagsmith_identity.identifier
        end
      end

      before do
        payload = { 'sub' => 'sub-only-123' }
        token = JWT.encode(payload, nil, 'none')
        cookies[TradeTariffFrontend.id_token_cookie_name] = token
      end

      it 'uses the sub claim as the user identifier' do
        get :index
        expect(response.body).to eq('User:sub-only-123')
      end
    end
  end

  describe '#migrate_anonymous_flagsmith_identity' do
    controller do
      def index
        render plain: 'ok'
      end
    end

    context 'with no JWT cookie (anonymous user)' do
      it 'does not call delete_identity' do
        allow(TEST_FLAGSMITH_CLIENT).to receive(:delete_identity).and_call_original
        get :index
        expect(TEST_FLAGSMITH_CLIENT).not_to have_received(:delete_identity)
      end
    end

    context 'with a JWT cookie but no anonymous cookie' do
      before do
        payload = { 'email' => 'neil@example.com' }
        token = JWT.encode(payload, nil, 'none')
        cookies[TradeTariffFrontend.id_token_cookie_name] = token
      end

      it 'does not delete the anonymous cookie (nothing to migrate)' do
        get :index
        expect(cookies[:flipper_anonymous_id]).to be_nil
      end
    end

    context 'with a JWT cookie AND an anonymous cookie' do
      before do
        payload = { 'email' => 'neil@example.com' }
        token = JWT.encode(payload, nil, 'none')
        cookies[TradeTariffFrontend.id_token_cookie_name] = token
        cookies[:flipper_anonymous_id] = 'anon-uuid-123'
      end

      it 'deletes the anonymous cookie after migration' do
        get :index
        expect(cookies[:flipper_anonymous_id]).to be_nil
      end

      it 'calls delete_identity on the Flagsmith client for the anonymous identifier' do
        allow(TEST_FLAGSMITH_CLIENT).to receive(:delete_identity).and_call_original
        get :index
        expect(TEST_FLAGSMITH_CLIENT).to have_received(:delete_identity).with('Anonymous:anon-uuid-123')
      end
    end
  end

  describe '#check_green_lanes_enabled' do
    controller do
      before_action :check_green_lanes_enabled

      def index
        render plain: 'ok'
      end
    end

    context 'when green_lanes flag is enabled' do
      before { enable_feature(:green_lanes) }

      it 'allows the request' do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when green_lanes flag is disabled' do
      it 'raises FeatureUnavailable' do
        expect { get :index }.to raise_error(TradeTariffFrontend::FeatureUnavailable)
      end
  describe '#append_info_to_payload' do
    it 'adds frontend and search request ids to the logging payload' do
      request.request_id = 'frontend-request-id'
      controller.instance_variable_set(:@search, Search.new(q: '94036099', request_id: 'search-request-id'))

      payload = {}
      controller.send(:append_info_to_payload, payload)

      expect(payload).to include(
        request_id: 'frontend-request-id',
        search_request_id: 'search-request-id',
      )
    end

    it 'adds structured details for handled Faraday errors' do
      error = Faraday::ServerError.new(
        'the server responded with status 500',
        response: {
          status: 500,
          body: { 'errors' => [{ 'detail' => 'backend exploded' }] },
          url: URI('https://backend.example.test/api/uk/search'),
        },
      )

      controller.instance_variable_set(:@search, Search.new(q: '94036099', request_id: 'search-request-id'))
      controller.instance_variable_set(:@handled_exception_log_context, controller.send(:handled_exception_log_context, error))

      payload = {}
      controller.send(:append_info_to_payload, payload)

      expect(payload).to include(
        exception_class: 'Faraday::ServerError',
        exception_message: 'the server responded with status 500',
        search_request_id: 'search-request-id',
        backend_status: 500,
        backend_url: 'https://backend.example.test/api/uk/search',
        backend_response_body: { 'errors' => [{ 'detail' => 'backend exploded' }] }.to_json,
        backend_response_body_truncated: false,
      )
    end
  end
end
