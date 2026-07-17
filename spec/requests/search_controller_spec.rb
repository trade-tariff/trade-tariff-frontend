require 'spec_helper'

RSpec.describe SearchController, type: :request do
  describe 'GET #search with hybrid_search on' do
    context 'with hybrid search enabled' do
      let(:commodity_data) do
        {
          'id' => '123',
          'type' => 'commodity',
          'attributes' => {
            'goods_nomenclature_item_id' => '0101210000',
            'producline_suffix' => GoodsNomenclature::NON_GROUPING_PRODUCTLINE_SUFFIX,
            'goods_nomenclature_class' => 'Commodity',
            'classification_description' => 'Pure-bred breeding animals',
            'formatted_description' => 'Pure-bred breeding animals',
            'declarable' => true,
            'score' => 12.5,
          },
        }
      end

      before do
        disable_feature(:interactive_search)
        enable_feature(:hybrid_search)
      end

      context 'when backend returns fuzzy matches' do
        before do
          stub_api_request('search', :post, internal: true).to_return(
            status: 200,
            body: { 'data' => [commodity_data] }.to_json,
            headers: { 'content-type' => 'application/json; charset=utf-8' },
          )

          get perform_search_path, params: { q: 'horses' }
        end

        it { expect(response).to have_http_status(:ok) }
        it { expect(response.body).to include 'Pure-bred breeding animals' }
      end

      context 'when backend returns exact match' do
        before do
          exact_match = commodity_data.deep_dup
          exact_match['attributes']['score'] = nil

          stub_api_request('search', :post, internal: true).to_return(
            status: 200,
            body: { 'data' => [exact_match] }.to_json,
            headers: { 'content-type' => 'application/json; charset=utf-8' },
          )

          get perform_search_path, params: { q: '0101210000' }
        end

        it { expect(response).to have_http_status(:redirect) }
        it { expect(response.location).to include commodity_path('0101210000') }
        it { expect(response.location).to include 'request_id=' }
      end

      context 'with JSON format' do
        before do
          stub_api_request('search', :post, internal: true).to_return(
            status: 200,
            body: { 'data' => [commodity_data] }.to_json,
            headers: { 'content-type' => 'application/json; charset=utf-8' },
            )

          get perform_search_path, params: { q: 'car parts', day: '5', month: '4', year: '2019' }, as: :json
          @body = JSON.parse(response.body)
        end

        it { expect(@body).to include('q' => 'car parts', 'as_of' => '2019-04-05') }
        it { expect(@body['results']).to be_an(Array) }
      end
    end
  end
end
