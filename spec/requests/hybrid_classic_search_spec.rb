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

  before do
    enable_feature(:hybrid_search)
  end

  describe 'exact match redirects' do
    it 'redirects a single unscored result to the matched commodity' do
      stub_internal_search([commodity_entry('0101210000', score: nil)])

      post perform_search_path, params: { q: '0101210000' }

      expect(response).to have_http_status(:redirect)
      expect(response.location).to match(%r{\Ahttp://www.example.com/commodities/0101210000\?request_id=.+\z})
    end
  end

  describe 'selected autocomplete suggestions' do
    it 'carries the selected resource id of a duplicate label to internal search' do
      stub = stub_api_request('search', :post, internal: true)
        .with { |request| JSON.parse(request.body)['resource_id'] == '0101220000' }
        .to_return(
          status: 200,
          body: { data: [commodity_entry('0101220000', score: nil)] }.to_json,
          headers: { 'content-type' => 'application/json; charset=utf-8' },
        )

      post perform_search_path, params: { q: 'Horses', resource_id: '0101220000' }

      expect(stub).to have_been_requested
      expect(response).to have_http_status(:redirect)
      expect(response.location).to match(%r{\Ahttp://www.example.com/commodities/0101220000\?request_id=.+\z})
    end
  end

  describe 'grouped heading and chapter results' do
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
      expect(page).to have_text('There is a problem with your search')
      expect(page).to have_text('Search term is not valid')
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

  describe 'flag disabled' do
    before do
      disable_feature(:hybrid_search)
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
