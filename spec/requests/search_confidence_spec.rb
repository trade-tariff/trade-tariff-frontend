require 'spec_helper'

RSpec.describe 'Search confidence', :aggregate_failures, type: :request do
  subject(:page) { Capybara.string(response.body) }

  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  let(:confidence) { 'strong' }
  let(:results) do
    [{
      id: '2007919930',
      type: 'commodity',
      attributes: {
        goods_nomenclature_item_id: '2007919930',
        goods_nomenclature_class: 'Commodity',
        description: 'Citrus jam',
        classification_description: 'Citrus jam',
        declarable: true,
        confidence:,
        score: 12.5,
      },
    }]
  end

  before do
    enable_feature(:interactive_search)
    stub_api_request('search', :post, internal: true).to_return(
      body: {
        data: results,
        meta: { interactive_search: { query: 'citrus jam', request_id: 'confidence-request', answers: [] } },
      }.to_json,
      headers: { 'content-type' => 'application/json' },
    )
  end

  it 'shows confidence on results and reload' do
    post perform_search_path, params: { q: 'citrus jam', interactive_search: 'true' }

    expect(page).to have_css('.confidence-label', exact_text: 'Strong result')
    expect(page).not_to have_text('How we calculate confidence')
    expect(page).to have_text('You are responsible for using the correct commodity codes')

    get perform_search_path, params: { q: 'citrus jam', interactive_search: 'true', request_id: 'confidence-request' }

    expect(response).to have_http_status(:ok)
    expect(Capybara.string(response.body)).to have_css('.confidence-label', exact_text: 'Strong result')
  end

  context 'without results' do
    let(:results) { [] }

    it 'retains the no-results page' do
      post perform_search_path, params: { q: 'citrus jam', interactive_search: 'true' }

      expect(page).to have_css('[data-guided-search-page-outcome-value="no_results"]')
      expect(page).not_to have_css('.confidence-indicator')
    end
  end

  context 'without confidence' do
    let(:confidence) { nil }

    it 'retains the unknown-results page' do
      post perform_search_path, params: { q: 'citrus jam', interactive_search: 'true' }

      expect(page).to have_css('[data-guided-search-page-outcome-value="unknown_results"]')
      expect(page).not_to have_css('.confidence-indicator')
    end
  end

  it 'retains backend error handling' do
    stub_api_request('search', :post, internal: true).to_return(status: 500)

    post perform_search_path, params: { q: 'citrus jam', interactive_search: 'true' }

    expect(response).to have_http_status(:internal_server_error)
    expect(page).not_to have_css('.confidence-indicator')
  end

  it 'retains validation error handling' do
    post perform_search_path, params: { q: '', interactive_search: 'true' }

    expect(page).to have_css('.govuk-error-summary')
    expect(page).not_to have_css('.confidence-indicator')
  end

  context 'with classic search' do
    before do
      stub_api_request('search', :post).to_return(jsonapi_response(:search, {
        type: 'fuzzy_match',
        goods_nomenclature_match: { chapters: [], headings: [], commodities: [], sections: [] },
        reference_match: { chapters: [], headings: [], commodities: [], sections: [] },
      }))
    end

    it 'does not show a confidence indicator' do
      post perform_search_path, params: { q: 'citrus jam' }

      expect(response).to have_http_status(:ok)
      expect(page).not_to have_css('.confidence-indicator')
      expect(page).not_to have_css('.interactive-result')
    end

    it 'does not bypass disabled eligibility' do
      disable_feature(:interactive_search)

      post perform_search_path, params: { q: 'citrus jam', interactive_search: 'true' }

      expect(response).to have_http_status(:ok)
      expect(page).not_to have_css('.interactive-result')
    end
  end
end
