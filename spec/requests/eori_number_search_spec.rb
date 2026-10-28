require 'spec_helper'

RSpec.describe 'EORI number searches', :aggregate_failures, type: :request do
  subject(:page) { Capybara.string(response.body) }

  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  let(:message) { 'The Online Trade Tariff does not recognise EORI numbers. Search using a commodity code or a description of your goods' }

  shared_examples 'an EORI number error on the find commodity page' do |search_term|
    it 'shows the error on the find commodity page without searching' do
      expect(response).to have_http_status(:ok)
      expect(page).to have_title(/\A\s*Error: /)
      expect(page).to have_css('h1', text: 'Find commodity codes, import duties, taxes and controls')
      expect(page).not_to have_text('Search results for')
      expect(page).to have_css('.govuk-error-summary[data-disable-auto-focus="true"]', text: 'There is a problem')
      expect(page).to have_link(message, href: '#search-keyword-q-field-error')
      expect(page).to have_css('#keyword-search-panel .govuk-form-group--error #revised-keyword-query-error', text: "Error: #{message}")
      expect(page).to have_css('label[for="search-keyword-q-field-error"]')
      expect(page).to have_css(
        "#autocomplete[data-input-id='search-keyword-q-field-error'][data-input-value='#{search_term}']" \
        '[data-input-error="true"][data-autofocus="true"]',
      )
      expect(page.find('#autocomplete')['data-described-by']).to end_with('revised-keyword-query-error')
      expect(page).to have_css('#keyword-search-panel .govuk-inset-text', text: 'You can check an EORI number on GOV.UK (opens in new tab).')
      expect(page).to have_css(
        '.govuk-inset-text a[href="https://www.gov.uk/check-eori-number"][target="_blank"][rel="noopener noreferrer"]',
        text: 'check an EORI number on GOV.UK (opens in new tab)',
      )
      expect(a_request(:any, /search/)).not_to have_been_made
    end
  end

  context 'with code or keyword search' do
    before { post perform_search_path, params: { q: 'gb 123 456 789' } }

    it_behaves_like 'an EORI number error on the find commodity page', 'gb 123 456 789'
  end

  context 'with hybrid search' do
    before do
      enable_feature(:hybrid_search)
      post perform_search_path, params: { q: 'GB123456789000' }
    end

    it_behaves_like 'an EORI number error on the find commodity page', 'GB123456789000'
  end

  context 'with the code or keyword tab when AI-assisted search is available' do
    before do
      enable_feature(:interactive_search)
      post perform_search_path, params: { q: 'GB1234567890123', interactive_search: 'false' }
    end

    it_behaves_like 'an EORI number error on the find commodity page', 'GB1234567890123'

    it 'keeps the code or keyword tab open' do
      expect(page).to have_css('[data-search-mode-initial-mode-value="keyword"]')
      expect(page).not_to have_css('#ai-search-panel .govuk-error-message')
    end
  end

  context 'with the XI service' do
    before { post '/xi/search', params: { q: 'XI123456789000' } }

    it_behaves_like 'an EORI number error on the find commodity page', 'XI123456789000'
  end

  context 'with a search term that is not an EORI number' do
    it 'searches as before' do
      empty_match = { chapters: [], headings: [], commodities: [], sections: [] }
      stub = stub_api_request('search', :post).to_return(
        jsonapi_response(:search, { type: 'fuzzy_match', goods_nomenclature_match: empty_match, reference_match: empty_match }),
      )
      post perform_search_path, params: { q: 'GB-123456789000' }

      expect(stub).to have_been_requested
      expect(page).not_to have_text(message)
    end
  end

  context 'with usage cookies accepted' do
    before do
      cookies['cookies_policy'] = { usage: true }.to_json
      post perform_search_path, params: { q: 'GB123456789000' }
    end

    it 'records an input error, not a search without results' do
      analytics = JSON.parse(page.find('#search-analytics-context', visible: :all).text(:all))

      expect(analytics).to include('search_mode' => 'keyword', 'search_state' => 'input_error')
      expect(page).not_to have_css('[data-controller~="guided-search-page"]', visible: :all)
    end
  end

  context 'with an invalid date' do
    it 'keeps the existing date error and does not search' do
      post perform_search_path, params: { q: 'GB123456789000', search: { 'as_of(3i)' => '22', 'as_of(2i)' => '0', 'as_of(1i)' => '2026' } }

      expect(response).to redirect_to(find_commodity_path(q: 'GB123456789000', invalid_date: true, day: '22', month: '0', year: '2026'))
      follow_redirect!
      expect(page).to have_css('.govuk-error-summary', text: 'Date of trade must be a real date')
      expect(page).to have_field('revised-keyword-query', with: 'GB123456789000')
      expect(a_request(:any, /search/)).not_to have_been_made
    end
  end
end
