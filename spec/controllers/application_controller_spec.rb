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

    it 'permits an experiment parameter before replacing it with trusted context' do
      previous = ActionController::Parameters.action_on_unpermitted_parameters
      ActionController::Parameters.action_on_unpermitted_parameters = :raise
      expect(get(:index, params: { experiment: 'spoofed' })).to have_http_status(:ok)
    ensure
      ActionController::Parameters.action_on_unpermitted_parameters = previous
    end
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

  describe '#interactive_search_enabled?' do
    controller do
      def index
        render plain: interactive_search_enabled?.to_s
      end
    end

    before do
      stub_const('ENV', ENV.to_hash.merge('ENVIRONMENT' => 'development'))
      allow(TradeTariffFrontend::ServiceChooser).to receive_messages(service_name: 'uk', xi?: false)
    end

    it 'uses the config default when the Flagsmith flag is not configured' do
      get :index

      expect(response.body).to eq('true')
    end
  end

  describe 'experiment enrolment resolution' do
    controller do
      def index
        render json: { experiment: Current.experiment,
                       traits: Current.flagsmith_optin_traits,
                       interactive_search_enabled: interactive_search_enabled? }
      end
    end

    let(:experiment) { Rails.application.config.experiment_urls.fetch(:trusted_trader_guided_search) }

    before do
      stub_const('ENV', ENV.to_hash.merge('ENVIRONMENT' => 'development'))
      allow(TradeTariffFrontend::ServiceChooser).to receive_messages(service_name: 'uk', xi?: false)
    end

    it 'merges the active enrolment into existing traits without overriding Flagsmith', :aggregate_failures do
      disable_feature(:interactive_search)
      session[:flagsmith_optin_traits] = { webchat: true, interactive_search: false }
      session[:experiment_url_optins] = ['stale', experiment.enrollment_token]
      travel_to(Time.utc(2026, 7, 27, 12)) { get :index }
      expect(response.parsed_body).to eq('experiment' => 'trstd-trdr',
                                         'traits' => { 'webchat' => true,
                                                       'interactive_search' => { 'value' => true, 'transient' => true } },
                                         'interactive_search_enabled' => false)
      expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
    end

    it 'retains future enrolments and prunes expired or malformed storage', :aggregate_failures do
      session[:experiment_url_optins] = [experiment.enrollment_token]
      travel_to(experiment.starts_on.in_time_zone(experiment.timezone) - 1.second) { get :index }
      expect(response.parsed_body['experiment']).to be_nil
      expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
      travel_to((experiment.ends_on + 1.day).in_time_zone(experiment.timezone)) { get :index }
      expect(session[:experiment_url_optins]).to eq([])
      session[:experiment_url_optins] = { bad: 'shape' }
      get :index
      expect(session[:experiment_url_optins]).to eq([])
    end
  end

  describe '#webchat_enabled?' do
    controller do
      def index
        render plain: webchat_enabled?.to_s
      end
    end

    before do
      stub_const('ENV', ENV.to_hash.merge('WEBCHAT_URL' => 'https://example.com/webchat'))
    end

    it 'uses the config default when the Flagsmith flag is not configured' do
      get :index

      expect(response.body).to eq('true')
    end
  end

  describe '#append_info_to_payload' do
    it 'adds frontend and search request ids to the logging payload' do
      request.request_id = 'frontend-request-id'
      Current.experiment = 'trstd-trdr'
      controller.instance_variable_set(:@search, Search.new(q: '94036099', request_id: 'search-request-id'))

      payload = {}
      controller.send(:append_info_to_payload, payload)

      expect(payload).to include(
        request_id: 'frontend-request-id',
        search_request_id: 'search-request-id',
        experiment_label: 'trstd-trdr',
      )
    end

    it 'adds structured details for handled Faraday errors' do
      Current.experiment = 'trstd-trdr'
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
        experiment_label: 'trstd-trdr',
        backend_status: 500,
        backend_url: 'https://backend.example.test/api/uk/search',
        backend_response_body: { 'errors' => [{ 'detail' => 'backend exploded' }] }.to_json,
        backend_response_body_truncated: false,
      )
    end
  end
end
