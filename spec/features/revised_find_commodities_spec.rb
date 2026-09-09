require 'spec_helper'

RSpec.describe 'Revised find commodity' do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  before do
    allow(TradeTariffFrontend).to receive(:environment).and_return('staging')
    enable_feature(:interactive_search)
    stub_api_request('search_suggestions').with(query: hash_including('q')).to_return(jsonapi_response(:search_suggestion, []))
  end

  context 'with JavaScript', :js do
    before { visit find_commodity_path }

    it 'has one primary heading in either mode', :aggregate_failures do
      expect(page).to have_css('h1', count: 1, visible: :visible)
      find('#ai-search-tab').click
      expect(page).to have_css('h1', count: 1, visible: :visible)
      expect(page).to have_css('legend', text: 'When are you planning to trade the products?')
    end

    it 'starts on keyword despite a saved mode', :aggregate_failures do
      page.execute_script("document.cookie = 'interactive_search=true; path=/'")
      visit find_commodity_path

      expect(page).to have_css('#keyword-search-tab[aria-selected="true"]')
      expect(page).to have_field('revised-keyword-query', visible: :visible)
      expect(page).not_to have_field('Describe the products you are trading', visible: :visible)
    end

    it 'restores a rejected keyword query and associates its hint', :aggregate_failures do
      fill_in 'revised-keyword-query', with: 'coffee beans'
      fill_in 'Month', with: '0'
      click_button 'Search for a commodity'

      expect(page).to have_content('You must enter a valid date')
      expect(page).to have_field('revised-keyword-query', with: 'coffee beans')
      find_field('revised-keyword-query').send_keys(' roasted')
      expect(page).to have_css('#revised-keyword-query[aria-describedby~="revised-keyword-hint"]')
    end

    it 'combines date and AI errors in one summary across mode switches', :aggregate_failures do
      find('#ai-search-tab').click
      fill_in 'Describe the products you are trading', with: 'fresh tomatoes'
      fill_in 'Month', with: '0'
      click_button 'Search for a commodity'
      expect(page).to have_content('You must enter a valid date')

      fill_in 'Describe the products you are trading', with: ''
      click_button 'Search for a commodity'
      expect(page).to have_css('.govuk-error-summary', count: 1)
      expect(page).to have_css('.govuk-error-summary:focus', text: 'Enter a search term')
      within '.govuk-error-summary' do
        expect(page).to have_content('You must enter a valid date')
      end

      find('#keyword-search-tab').click
      within '.govuk-error-summary' do
        expect(page).to have_content('You must enter a valid date')
        expect(page).not_to have_css('li', text: 'Enter a search term', visible: :visible)
      end
      find('#ai-search-tab').click
      expect(page).to have_css('.govuk-error-summary', count: 1, text: 'Enter a search term')
    end

    it 'keeps drafts and the shared date', :aggregate_failures do
      fill_in 'revised-keyword-query', with: 'tomatoes'
      fill_in 'Day', with: '12'
      fill_in 'Month', with: '10'
      fill_in 'Year', with: '2026'
      find('#ai-search-tab').click
      fill_in 'Describe the products you are trading', with: 'fresh tomatoes'
      find('#keyword-search-tab').click

      expect(page).to have_field('revised-keyword-query', with: 'tomatoes')
      find('#ai-search-tab').click
      expect(page).to have_field('Describe the products you are trading', with: 'fresh tomatoes')
      expect(page).to have_field('Day', with: '12')
      expect(page).to have_field('Month', with: '10')
      expect(page).to have_field('Year', with: '2026')
      submitted_queries = page.evaluate_script(<<~JS)
        Array.from(new FormData(document.querySelector('#new_search')))
          .filter(([name]) => name === 'q' || name === 'search[q]')
          .map(([, value]) => value)
      JS
      expect(submitted_queries).to eq(['fresh tomatoes'])
    end

    it 'supports keyboard tabs and newlines', :aggregate_failures do
      find('#keyword-search-tab').send_keys(:right)
      expect(page).to have_css('#ai-search-tab[aria-selected="true"]:focus')
      description = find_field('Describe the products you are trading')
      description.send_keys('fresh', :enter, 'tomatoes')

      expect(description.value).to eq("fresh\ntomatoes")
      expect(page).to have_current_path(find_commodity_path)
      find('#ai-search-tab').send_keys(:left)
      expect(page).to have_css('#keyword-search-tab[aria-selected="true"]:focus')
    end

    it 'submits AI text into the journey' do
      stub_api_request('search', :post, internal: true)
        .with { |request| JSON.parse(request.body)['q'] == 'fresh tomatoes' }
        .to_return(
          body: {
            data: [],
            meta: {
              interactive_search: {
                query: 'fresh tomatoes',
                request_id: 'revised-journey',
                answers: [{ question: 'How are the tomatoes prepared?', options: %w[Fresh Dried], answer: nil }],
              },
            },
          }.to_json,
          headers: { 'content-type' => 'application/json' },
        )
      fill_in 'revised-keyword-query', with: 'unused keyword'
      find('#ai-search-tab').click
      fill_in 'Describe the products you are trading', with: 'fresh tomatoes'
      click_button 'Search for a commodity'

      expect(page).to have_content('How are the tomatoes prepared?')
    end

    it 'hides AI errors in keyword mode', :aggregate_failures do
      find('#ai-search-tab').click
      click_button 'Search for a commodity'
      expect(page).to have_css('.govuk-error-summary', text: 'Enter a search term')

      find('#keyword-search-tab').click
      expect(page).not_to have_css('.govuk-error-summary', visible: :visible)
      expect(page).to have_field('revised-keyword-query', visible: :visible)
    end

    context 'with a mobile viewport' do
      before { page.current_window.resize_to(375, 812) }

      after { page.current_window.resize_to(1200, 800) }

      it 'keeps one usable search panel', :aggregate_failures do
        expect(page).to have_field('revised-keyword-query', visible: :visible)
        expect(page).not_to have_field('Describe the products you are trading', visible: :visible)
        find('#ai-search-tab').click
        expect(page).to have_field('Describe the products you are trading', visible: :visible)
        expect(page).not_to have_field('revised-keyword-query', visible: :visible)
        expect(page.evaluate_script('document.documentElement.scrollWidth <= window.innerWidth')).to be(true)
      end
    end
  end

  context 'without JavaScript' do
    before do
      stub_api_request('search', :post).to_return(jsonapi_response(:search, attributes_for(:search_outcome, :fuzzy_match)))
      visit find_commodity_path
    end

    it 'submits a usable keyword search', :aggregate_failures do
      expect(find_field('revised-keyword-query')['aria-describedby']).to eq('revised-keyword-hint')
      fill_in 'revised-keyword-query', with: 'toothbrush'
      click_button 'Search for a commodity'

      expect(page).to have_css('h1', text: 'Search results')
      expect(page).to have_current_path('/search')
    end
  end
end
