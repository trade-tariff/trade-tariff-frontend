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
        expect(cookies[:flagsmith_anonymous_id]).to be_present
      end
    end

    context 'with a JWT cookie' do
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

      it 'keeps using the anonymous identity for feature targeting' do
        get :index
        expect(response.body).to start_with('Anonymous:')
      end
    end
  end

  describe '#flagsmith_feature_enabled?' do
    controller do
      def index
        2.times { flagsmith_feature_enabled?(:interactive_search) }
        render plain: 'ok'
      end
    end

    it 'does not retry Flagsmith after a failed flag fetch in the same request' do
      allow(FlagsmithClient.instance).to receive(:get_flags_for).and_raise(Faraday::ConnectionFailed.new('timeout'))

      get :index

      expect(FlagsmithClient.instance).to have_received(:get_flags_for).once
    end

    context 'when on the XI service' do
      controller do
        def index
          render plain: flagsmith_feature_enabled?(:interactive_search).to_s
        end
      end

      before do
        allow(TradeTariffFrontend::ServiceChooser).to receive(:xi?).and_return(true)
        enable_feature(:interactive_search)
      end

      it 'returns the raw Flagsmith flag value' do
        get :index

        expect(response.body).to eq('true')
      end
    end
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
