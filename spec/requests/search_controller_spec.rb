require 'spec_helper'

RSpec.describe SearchController, type: :request do
  describe 'unavailable internal suggestions' do
    %i[search_suggestions_path interactive_search_suggestions_path].each do |route|
      context "with #{route}" do
        before { enable_feature(:interactive_search) }

        [Faraday::TimeoutError, Faraday::ConnectionFailed, Faraday::ServerError].each do |error|
          it "returns empty suggestions for #{error}", :aggregate_failures do
            stub_api_request('search_suggestions', internal: true)
              .with(query: { q: 'Horses' }).to_raise(error)

            get public_send(route), params: { term: 'Horses' }

            expect(response).to have_http_status(:ok)
            expect(response.parsed_body).to eq('results' => [], 'use_resource_ids' => true)
          end
        end
      end
    end
  end

  # A browser keeps the original Referer across redirects. Redirecting an empty search
  # back to a search page sends the browser to /search again with the same Referer. That
  # loops until the browser gives up after about 20 redirects.
  describe 'an empty search from a search page' do
    before do
      %w[uk xi].each do |backend|
        TradeTariffFrontend::ServiceChooser.with_source(backend) do
          stub_api_request('search', :post, internal: true).to_return(
            status: 200,
            body: { data: [] }.to_json,
            headers: { 'content-type' => 'application/json; charset=utf-8' },
          )
        end
      end
    end

    {
      '/search' => '/find_commodity',
      '/uk/search' => '/find_commodity',
      '/search?year=2025' => '/find_commodity',
      '/search?q=' => '/find_commodity',
      '/xi/search' => '/xi/find_commodity',
    }.each do |referer_path, expected_redirect|
      context "when the request is GET #{referer_path}" do
        let(:request_path) { referer_path.split('?').first }

        it "redirects to #{expected_redirect}", :aggregate_failures do
          get request_path, headers: { 'Referer' => "http://www.example.com#{referer_path}" }

          expect(response).to redirect_to(expected_redirect)
        end
      end
    end

    it 'redirects a POST to the find commodity page' do
      post '/search', headers: { 'Referer' => 'http://www.example.com/search' }

      expect(response).to redirect_to('/find_commodity')
    end

    it 'redirects a POST in the XI service to the XI find commodity page' do
      post '/xi/search', headers: { 'Referer' => 'http://www.example.com/xi/search' }

      expect(response).to redirect_to('/xi/find_commodity')
    end

    it 'still redirects back to a page that is not a search page' do
      get '/search', headers: { 'Referer' => 'http://www.example.com/chapters/01' }

      expect(response).to redirect_to('/chapters/01?')
    end
  end

  describe 'POST /search' do
    context 'when guided search advances to a new question' do
      before do
        enable_feature(:interactive_search)
        stub_api_request('search', :post, internal: true).to_return(
          status: 200,
          body: {
            data: [],
            meta: {
              interactive_search: {
                query: 'horse',
                request_id: 'guided-request-123',
                answers: [
                  { question: 'What is the horse used for?', options: %w[Sport Other], answer: 'Other' },
                  { question: 'What is it made from?', options: %w[Wood Other], answer: nil },
                ],
              },
            },
          }.to_json,
          headers: { 'content-type' => 'application/json; charset=utf-8' },
        )
      end

      it 'does not select the previous answer' do
        post perform_search_path,
             params: {
               q: 'horse',
               interactive_search: 'true',
               request_id: 'guided-request-123',
               current_question: 'What is the horse used for?',
               current_options: %w[Sport Other].to_json,
               interactive_search_form: { answer: 'Other' },
             }

        expect(Capybara.string(response.body)).to have_unchecked_field('Other')
      end
    end

    context 'when calculator results are rendered from a POST' do
      around do |example|
        original_store = ActionController::Base.cache_store
        ActionController::Base.cache_store = ActiveSupport::Cache::MemoryStore.new
        example.run
      ensure
        ActionController::Base.cache_store = original_store
      end

      before do
        allow(Rails).to receive(:cache).and_return(ActionController::Base.cache_store)
        allow(TradeTariffFrontend).to receive_messages(
          duty_calculator_homepage_card_enabled?: true,
          interactive_search_enabled?: true,
        )
        stub_api_request('search', :post, internal: true).to_return(
          body: {
            data: [{
              id: '2007919930',
              type: 'commodity',
              attributes: {
                goods_nomenclature_item_id: '2007919930',
                goods_nomenclature_class: 'Commodity',
                description: 'Citrus jam',
                classification_description: 'Citrus jam',
                declarable: true,
                confidence: 'strong',
                score: 12.5,
              },
            }],
            meta: {
              interactive_search: {
                query: 'citrus jam',
                request_id: 'calculator-request-123',
                answers: [
                  { question: 'What is it made from?', options: %w[Wood Metal], answer: 'Wood' },
                  { question: 'What type of fruit?', options: %w[Citrus Berry], answer: 'Citrus' },
                ],
              },
            },
          }.to_json,
          headers: { 'content-type' => 'application/json' },
        )
      end

      it 'replays the normalized search state from an opaque results path', :aggregate_failures do
        post perform_search_path, params: {
          q: 'citrus jam',
          interactive_search: 'true',
          duty_calculator: 'true',
          request_id: 'calculator-request-123',
          answers: [{ question: 'What is it made from?', options: %w[Wood Metal], answer: 'Wood' }],
          current_question: 'What type of fruit?',
          current_options: %w[Citrus Berry].to_json,
          interactive_search_form: { answer: 'Citrus' },
          day: '21',
          month: '10',
          year: '2026',
        }

        expect(response).to have_http_status(:ok)

        link = Capybara.string(response.body).find_link('Calculate import costs on this commodity')
        import_details_query = Rack::Utils.parse_query(URI(link[:href]).query)
        search_results_path = import_details_query.fetch('search_results_path')
        search_results_uri = URI(search_results_path)
        search_results_query = Rack::Utils.parse_query(search_results_uri.query)

        expect(search_results_path.bytesize).to be <= 256
        expect(search_results_uri.path).to eq('/search')
        expect(search_results_query).to include(
          'search_results_id' => a_string_matching(/\A[a-f0-9]{32}\z/),
          'day' => '21',
          'month' => '10',
          'year' => '2026',
        )
        expect(session).not_to have_key(InteractiveSearchable::SEARCH_RESULTS_STATE_SESSION_KEY)

        get search_results_path

        expect(response).to have_http_status(:ok)
        expect(Capybara.string(response.body)).to have_link('Calculate import costs on this commodity')
        expect(Capybara.string(response.body)).to have_text('Citrus jam')
        expect(WebMock).to have_requested(:post, %r{#{internal_api_path}/search$}).once
      end

      it 'keeps the opaque results path usable when the cache is disabled', :aggregate_failures do
        allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::NullStore.new)

        post perform_search_path, params: {
          q: 'citrus jam',
          interactive_search: 'true',
          duty_calculator: 'true',
          request_id: 'calculator-request-123',
          answers: [{ question: 'What is it made from?', options: %w[Wood Metal], answer: 'Wood' }],
          current_question: 'What type of fruit?',
          current_options: %w[Citrus Berry].to_json,
          interactive_search_form: { answer: 'Citrus' },
          day: '21',
          month: '10',
          year: '2026',
        }

        link = Capybara.string(response.body).find_link('Calculate import costs on this commodity')
        search_results_path = Rack::Utils.parse_query(URI(link[:href]).query).fetch('search_results_path')

        get search_results_path

        expect(response).to have_http_status(:ok)
        expect(Capybara.string(response.body)).to have_text('Citrus jam')
      end

      it 'restarts an expired calculator search at the goods description step' do
        get perform_search_path(search_results_id: '0123456789abcdef0123456789abcdef')

        expect(response).to redirect_to(what_are_you_importing_path)
      end

      it 'restarts the calculator search when the session fallback exceeds its size limit', :aggregate_failures do
        allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::NullStore.new)
        session_cookie = Rails.application.config.session_options.fetch(:key)
        jar = ActionDispatch::Request.new(Rails.application.env_config.dup).cookie_jar
        jar.encrypted[session_cookie] = {
          value: { session_id: SecureRandom.hex(16), existing_state: 'x' * 2_050 },
        }
        cookies[session_cookie] = jar[session_cookie]

        post perform_search_path, params: {
          q: 'citrus jam',
          interactive_search: 'true',
          duty_calculator: 'true',
          request_id: 'calculator-request-123',
          answers: [{ question: 'What is it made from?', options: %w[Wood Metal], answer: 'Wood' }],
          current_question: 'What type of fruit?',
          current_options: %w[Citrus Berry].to_json,
          interactive_search_form: { answer: 'Citrus' },
          day: '21',
          month: '10',
          year: '2026',
        }

        link = Capybara.string(response.body).find_link('Calculate import costs on this commodity')
        search_results_path = Rack::Utils.parse_query(URI(link[:href]).query).fetch('search_results_path')
        restart_path = what_are_you_importing_path(day: nil, month: nil, year: nil)

        expect(search_results_path).to eq(restart_path)
        expect(session).not_to have_key(InteractiveSearchable::SEARCH_RESULTS_STATE_SESSION_KEY)

        get perform_search_path(search_results_id: '0123456789abcdef0123456789abcdef')

        expect(response).to redirect_to(restart_path)
      end
    end
  end
end
