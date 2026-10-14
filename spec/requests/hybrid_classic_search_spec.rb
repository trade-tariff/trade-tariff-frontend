require 'spec_helper'

RSpec.describe 'Hybrid classic search', :aggregate_failures, type: :request do
  subject(:page) { Capybara.string(response.body) }

  def commodity_entry(goods_nomenclature_item_id, overrides = {})
    {
      id: goods_nomenclature_item_id,
      type: 'commodity',
      attributes: {
        goods_nomenclature_item_id:,
        producline_suffix: GoodsNomenclature::NON_GROUPING_PRODUCTLINE_SUFFIX,
        goods_nomenclature_class: 'Commodity',
        description: 'Horses',
        formatted_description: 'Horses',
        declarable: true,
        score: 12.5,
      }.merge(overrides),
    }
  end

  def stub_internal_search(results, meta = nil)
    stub_api_request('search', :post, internal: true)
      .to_return(
        status: 200,
        body: { data: results }.merge(meta ? { meta: } : {}).to_json,
        headers: { 'content-type' => 'application/json; charset=utf-8' },
      )
  end

  def stub_autocomplete(ids, internal: true)
    stub_api_request('search_suggestions', internal:)
      .with(query: { q: 'Horses' })
      .to_return(
        status: 200,
        body: { data: ids.map { |id| { id:, type: 'search_suggestion', attributes: { value: 'Horses' } } } }.to_json,
        headers: { 'content-type' => 'application/json; charset=utf-8' },
      )
  end

  before do
    enable_feature(:hybrid_search)
  end

  describe 'exact match redirects' do
    it 'redirects a single unscored result to the matched commodity' do
      stub_internal_search([commodity_entry('0101210000', score: nil)])

      post perform_search_path, params: { q: '0101210000', request_id: 'classic-request' }

      expect(response).to redirect_to(commodity_path('0101210000', request_id: 'classic-request'))
    end
  end

  describe 'selected autocomplete suggestions' do
    %w[uk xi].each do |service|
      it "uses internal autocomplete on #{service}" do
        TradeTariffFrontend::ServiceChooser.with_source(service) do
          stub = stub_autocomplete(%w[12345])

          get search_suggestions_path, params: { term: 'Horses' }

          expect(response).to have_http_status(:ok)
          expect(stub).to have_been_requested
          expect(response.parsed_body['results'].first).to include('text' => 'Horses', 'resource_id' => '12345')
        end
      end
    end

    it 'preserves the selected SID when its restored label needs query normalization' do
      label = ' [Horses] '
      stub = stub_api_request('search', :post, internal: true)
        .with { |request| JSON.parse(request.body).slice('q', 'resource_id') == { 'q' => 'Horses', 'resource_id' => '67890' } }
        .to_return(
          status: 200,
          body: { data: [commodity_entry('0101220000', score: nil)] }.to_json,
          headers: { 'content-type' => 'application/json' },
        )

      post perform_search_path, params: {
        q: label,
        resource_id: '67890',
        resource_id_query: label,
        request_id: 'normalized-label-request',
      }

      expect(stub).to have_been_requested
      expect(response).to redirect_to(commodity_path('0101220000', request_id: 'normalized-label-request'))
    end

    it 'preserves the selected SID for a duplicate label' do
      stub_autocomplete(%w[12345 67890])
      get search_suggestions_path, params: { term: 'Horses' }
      selected = response.parsed_body['results'].last

      stub = stub_api_request('search', :post, internal: true)
        .with { |request| JSON.parse(request.body)['resource_id'] == '67890' }
        .to_return(
          status: 200,
          body: { data: [commodity_entry('0101220000', score: nil)] }.to_json,
          headers: { 'content-type' => 'application/json; charset=utf-8' },
        )

      post perform_search_path, params: {
        q: selected['text'],
        resource_id: selected['resource_id'],
        request_id: 'classic-request',
        search: { 'as_of(1i)' => '2026', 'as_of(2i)' => '10', 'as_of(3i)' => '14' },
      }

      expect(stub).to have_been_requested
      expect(response).to redirect_to(commodity_path('0101220000', request_id: 'classic-request'))
    end
  end

  describe 'invalid dates with a selected suggestion' do
    include_context 'with latest news stubbed'
    include_context 'with news updates stubbed'

    %w[classic revised].each do |layout|
      it "retains the query and SID while correcting the date on the #{layout} page" do
        enable_feature(:interactive_search) if layout == 'revised'
        post perform_search_path, params: {
          q: 'Horses',
          resource_id: '67890',
          search: { 'as_of(1i)' => '2026', 'as_of(2i)' => '2', 'as_of(3i)' => '31' },
        }

        expect(URI.decode_www_form(URI(response.location).query).to_h).to include(
          'q' => 'Horses', 'resource_id' => '67890', 'invalid_date' => 'true',
        )
        follow_redirect!
        error_page = Capybara.string(response.body)
        input_id = layout == 'revised' ? 'revised-keyword-query' : 'search-q-field'
        expect(error_page).to have_field(input_id, with: 'Horses')
        expect(error_page).to have_css('.govuk-error-summary', text: 'Date of trade must be a real date')
        selected_id = error_page.find('input[name="resource_id"]', visible: :hidden).value
        expect(selected_id).to eq('67890')
        selected_query = error_page.find('input[name="resource_id_query"]', visible: :hidden).value
        expect(selected_query).to eq('Horses')

        stub = stub_api_request('search', :post, internal: true)
          .with { |request| JSON.parse(request.body)['resource_id'] == '67890' }
          .to_return(
            status: 200,
            body: { data: [commodity_entry('0101220000', score: nil)] }.to_json,
            headers: { 'content-type' => 'application/json' },
          )
        post perform_search_path, params: {
          q: error_page.find_field(input_id).value,
          resource_id: selected_id,
          resource_id_query: selected_query,
          request_id: 'corrected-date-request',
          search: { 'as_of(1i)' => '2026', 'as_of(2i)' => '2', 'as_of(3i)' => '28' },
        }

        expect(stub).to have_been_requested
        expect(response).to redirect_to(commodity_path('0101220000', request_id: 'corrected-date-request'))
      end
    end
  end

  describe 'edited unenhanced search queries' do
    include_context 'with latest news stubbed'
    include_context 'with news updates stubbed'

    it 'ignores a restored SID when its original query no longer matches' do
      post perform_search_path, params: {
        q: 'Horses',
        resource_id: '67890',
        search: { 'as_of(1i)' => '2026', 'as_of(2i)' => '2', 'as_of(3i)' => '31' },
      }
      follow_redirect!
      error_page = Capybara.string(response.body)
      restored_id = error_page.find('input[name="resource_id"]', visible: :hidden).value
      original_query = error_page.find('input[name="resource_id_query"]', visible: :hidden).value
      stub = stub_api_request('search', :post, internal: true)
        .with { |request| JSON.parse(request.body)['q'] == 'horse toys' && !JSON.parse(request.body).key?('resource_id') }
        .to_return(status: 200, body: { data: [] }.to_json, headers: { 'content-type' => 'application/json' })

      post perform_search_path, params: {
        q: 'horse toys',
        resource_id: restored_id,
        resource_id_query: original_query,
        search: { 'as_of(1i)' => '2026', 'as_of(2i)' => '2', 'as_of(3i)' => '28' },
      }

      expect(stub).to have_been_requested
      expect(response).to have_http_status(:ok)
      expect(page).to have_text('There are no results matching your query')
    end
  end

  describe 'grouped heading and chapter results' do
    it 'uses full included ancestor descriptions for a primary commodity' do
      commodity = commodity_entry('0101210000')
      commodity[:relationships] = { heading: { data: { id: '0101000000', type: 'heading' } } }
      stub_api_request('search', :post, internal: true).to_return(
        status: 200,
        body: {
          data: [commodity],
          included: [
            {
              id: '0101000000',
              type: 'heading',
              attributes: {
                goods_nomenclature_item_id: '0101000000',
                goods_nomenclature_class: 'Heading',
                description: 'Live horses',
                self_text: 'Horses: live animals',
              },
              relationships: { chapter: { data: { id: '0100000000', type: 'chapter' } } },
            },
            {
              id: '0100000000',
              type: 'chapter',
              attributes: {
                goods_nomenclature_item_id: '0100000000',
                goods_nomenclature_class: 'Chapter',
                description: 'Live animals',
                self_text: 'Animals: live',
              },
            },
          ],
        }.to_json,
        headers: { 'content-type' => 'application/json' },
      )

      post perform_search_path, params: { q: 'horses' }

      expect(response).to have_http_status(:ok)
      expect(page).to have_link('Horses: live animals', href: %r{/headings/0101\?request_id=.+})
      expect(page).to have_link('Animals: live', href: %r{/chapters/01\?request_id=.+})
    end

    it 'renders headings grouped under the chapter from the response linkage' do
      stub_api_request('search', :post, internal: true)
        .to_return(
          status: 200,
          body: {
            data: [
              {
                id: '0101000000',
                type: 'heading',
                attributes: {
                  goods_nomenclature_item_id: '0101000000',
                  producline_suffix: GoodsNomenclature::NON_GROUPING_PRODUCTLINE_SUFFIX,
                  goods_nomenclature_class: 'Heading',
                  description: 'Live horses',
                  formatted_description: 'Live horses',
                  self_text: 'Live horses: pure-bred and other',
                  declarable: false,
                  score: 10.0,
                },
                relationships: {
                  chapter: { data: { id: '0100000000', type: 'chapter' } },
                },
              },
            ],
            included: [
              {
                id: '0100000000',
                type: 'chapter',
                attributes: {
                  goods_nomenclature_item_id: '0100000000',
                  producline_suffix: GoodsNomenclature::NON_GROUPING_PRODUCTLINE_SUFFIX,
                  goods_nomenclature_class: 'Chapter',
                  description: 'Live animals',
                  formatted_description: 'Live animals',
                },
              },
            ],
          }.to_json,
          headers: { 'content-type' => 'application/json; charset=utf-8' },
        )

      post perform_search_path, params: { q: 'horses' }

      expect(response).to have_http_status(:ok)
      expect(page).to have_text('Other results containing the term')
      expect(page).to have_link('Live animals', href: %r{/chapters/01\?request_id=.+})
      expect(page).to have_link('Live horses: pure-bred and other', href: %r{/headings/0101\?request_id=.+})
    end
  end

  describe 'empty results' do
    before do
      stub_internal_search([])
    end

    it 'renders the classic no-results page' do
      post perform_search_path, params: { q: 'xyznonexistent' }

      expect(response).to have_http_status(:ok)
      expect(page).to have_text('There are no results matching your query')
    end

    it 'returns an empty JSON result set instead of failing' do
      get perform_search_path(format: :json), params: { q: 'xyznonexistent' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['results']).to eq([])
    end
  end

  describe 'backend validation errors' do
    before do
      stub_api_request('search', :post, internal: true)
        .to_return(
          status: 422,
          body: {
            errors: [
              {
                status: '422',
                title: 'Invalid query',
                detail: 'Search term is not valid',
                source: { pointer: '/data/attributes/q' },
              },
            ],
          }.to_json,
          headers: { 'content-type' => 'application/json; charset=utf-8' },
        )
    end

    it 'shows the validation problem instead of the no-results page' do
      post perform_search_path, params: { q: '0101210000' }

      expect(response).to have_http_status(:ok)
      expect(page).to have_css('.govuk-error-summary', count: 1, text: 'Search term is not valid')
      expect(page).to have_css('.govuk-error-message', count: 1, text: 'Search term is not valid')
      expect(page).to have_css('#autocomplete[data-input-value="0101210000"]')
      expect(page).to have_field('search-q-field-error', with: '0101210000')
      expect(page.find('article.search-results')).not_to have_text('Search term is not valid')
      expect(page).not_to have_text('There are no results matching your query')
    end
  end

  describe 'blocking description intercepts' do
    before do
      stub_internal_search(
        [commodity_entry('0101210000')],
        description_intercept: {
          excluded: true,
          message_header: 'Sending a set',
          message: 'Sets should be classified under the individual headings for each item.',
        },
      )
    end

    it 'renders the blocking guidance instead of the results' do
      post perform_search_path, params: { q: 'horses' }

      expect(response).to have_http_status(:ok)
      expect(page).to have_text('Search results for')
      expect(page).to have_text('Sending a set')
      expect(page).to have_text('Sets should be classified under the individual headings for each item.')
      expect(page).not_to have_text('Best commodity matches for')
      expect(page).not_to have_css('[data-guided-search-page-outcome-value]')
      expect(page).not_to have_text('Start search again')
    end
  end

  describe 'guided search alongside the hybrid flag' do
    before do
      enable_feature(:interactive_search)
    end

    let!(:stub) do
      guided_request = lambda do |request|
        body = JSON.parse(request.body)
        !body.key?('skip_question') && !body.key?('retrieval_method') && !body.key?('include')
      end
      stub_api_request('search', :post, internal: true)
        .with(&guided_request)
        .to_return(
          status: 200,
          body: {
            data: [],
            meta: {
              interactive_search: {
                query: 'horse',
                request_id: 'guided-request-123',
                answers: [
                  { question: 'What is the horse used for?', options: %w[Sport Other], answer: nil },
                ],
              },
            },
          }.to_json,
          headers: { 'content-type' => 'application/json; charset=utf-8' },
        )
    end

    it 'keeps the guided question flow unchanged' do
      post perform_search_path, params: { q: 'horse', interactive_search: 'true' }

      expect(stub).to have_been_requested
      expect(response).to have_http_status(:ok)
      expect(page).to have_css('[data-guided-search-page-outcome-value="question"]')
    end
  end

  describe 'experiment URL opt-in' do
    include_context 'with latest news stubbed'
    include_context 'with news updates stubbed'

    let(:experiment) { Rails.application.config.experiment_urls.fetch(:hybrid_search_demo) }
    let(:segment_enabled) { true }
    let(:evaluated_traits) { [] }
    let!(:v2_search) do
      stub_api_request('search', :post).to_return(
        jsonapi_response(:search, {
          type: 'fuzzy_match',
          goods_nomenclature_match: { chapters: [], headings: [], commodities: [], sections: [] },
          reference_match: { chapters: [], headings: [], commodities: [], sections: [] },
        }),
      )
    end

    around do |example|
      travel_to(Time.utc(2026, 10, 14, 12)) { example.run }
    end

    before do
      allow(FlagsmithClient.instance).to receive(:get_flags_for) do |_identity, traits|
        evaluated_traits << traits.deep_dup
        TestFlagsmithClient::TestFlags.new('hybrid_search' => segment_enabled && traits.dig('hybrid_search', :value) == true)
      end
    end

    it 'keeps unenrolled visitors on V2 search and autocomplete' do
      autocomplete = stub_autocomplete(%w[suggestion-row], internal: false)

      get search_suggestions_path, params: { term: 'Horses' }
      post perform_search_path, params: { q: 'horses' }

      expect(response).to have_http_status(:ok)
      expect(autocomplete).to have_been_requested
      expect(v2_search).to have_been_requested
      expect(evaluated_traits.last).not_to have_key('hybrid_search')
      expect(a_request(:post, internal_api_path('search'))).not_to have_been_requested
    end

    it 'enrols the browser into hybrid classic search and autocomplete' do
      get experiment.path, params: { experiment: 'spoofed' }

      expect(response).to redirect_to('/find_commodity?experiment=hybrid-demo')
      expect(response.headers.fetch('Cache-Control')).to include('no-store')
      expect(session[:experiment_url_optins]).to eq([experiment.enrollment_token])
      expect(experiment.feature_names).to eq(%w[hybrid_search])

      follow_redirect!
      expect(Capybara.string(response.body)).not_to have_link('AI-assisted search')

      autocomplete = stub_autocomplete(%w[12345])
      get search_suggestions_path, params: { term: 'Horses' }
      expect(autocomplete).to have_been_requested
      expect(response.parsed_body['results'].first['resource_id']).to eq('12345')

      stub_internal_search([])
      post perform_search_path, params: { q: 'horses' }

      expect(response).to have_http_status(:ok)
      expect(page).to have_text('There are no results matching your query')
      expect(v2_search).not_to have_been_requested
      expect(evaluated_traits.last).to include('hybrid_search' => { value: true, transient: true })
      expect(evaluated_traits.last).not_to have_key('interactive_search')
      expect(TEST_FLAGSMITH_MANAGEMENT_CLIENT.recorded_traits).to be_empty
    end

    it 'returns to V2 after the opt-in is cleared' do
      get experiment.path
      patch feature_flag_path('hybrid_search'), params: { enabled: 'false' }
      post perform_search_path, params: { q: 'horses' }

      expect(response).to have_http_status(:ok)
      expect(session[:experiment_url_optins]).to be_empty
      expect(v2_search).to have_been_requested
      expect(evaluated_traits.last).not_to have_key('hybrid_search')
    end

    it 'respects the operator OFF switch' do
      stub_const('ENV', ENV.to_hash.merge('HYBRID_SEARCH' => 'false'))
      autocomplete = stub_autocomplete(%w[suggestion-row], internal: false)

      get experiment.path
      get search_suggestions_path, params: { term: 'Horses' }
      post perform_search_path, params: { q: 'horses' }

      expect(response).to have_http_status(:ok)
      expect(autocomplete).to have_been_requested
      expect(v2_search).to have_been_requested
      expect(a_request(:post, internal_api_path('search'))).not_to have_been_requested
    end

    it 'does not enrol XI through the UK experiment' do
      get "/xi#{experiment.path}"

      expect(response).to redirect_to('/xi/find_commodity')
      expect(session[:experiment_url_optins]).to be_blank
    end

    context 'when Flagsmith does not enable the opt-in segment' do
      let(:segment_enabled) { false }

      it 'does not force hybrid search on' do
        get experiment.path
        post perform_search_path, params: { q: 'horses' }

        expect(response).to have_http_status(:ok)
        expect(v2_search).to have_been_requested
        expect(evaluated_traits.last).to include('hybrid_search' => { value: true, transient: true })
        expect(a_request(:post, internal_api_path('search'))).not_to have_been_requested
      end
    end
  end

  describe 'flag disabled' do
    before do
      disable_feature(:hybrid_search)
    end

    it 'keeps public V2 autocomplete' do
      stub = stub_autocomplete(%w[suggestion-row], internal: false)

      get search_suggestions_path, params: { term: 'Horses' }

      expect(response).to have_http_status(:ok)
      expect(stub).to have_been_requested
      expect(response.parsed_body['results'].first['resource_id']).to eq('suggestion-row')
      expect(a_request(:get, "#{internal_api_host}/search_suggestions")).not_to have_been_requested
    end

    it 'uses the V2 search endpoint' do
      stub = stub_api_request('search', :post).to_return(
        jsonapi_response(:search, {
          type: 'fuzzy_match',
          goods_nomenclature_match: { chapters: [], headings: [], commodities: [], sections: [] },
          reference_match: { chapters: [], headings: [], commodities: [], sections: [] },
        }),
      )

      post perform_search_path, params: { q: 'horses' }

      expect(response).to have_http_status(:ok)
      expect(stub).to have_been_requested
      expect(a_request(:post, internal_api_path('search'))).not_to have_been_requested
    end
  end
end
