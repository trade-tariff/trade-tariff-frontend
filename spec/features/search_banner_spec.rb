require 'spec_helper'

RSpec.describe 'Search banner', js: true do
  before { allow(TradeTariffFrontend).to receive(:search_banner?).and_return true }

  context 'when hitting the autocomplete fields' do
    it 'fetches data from the server as we type' do
      VCR.use_cassette('search#gold') do
        visit browse_sections_path

        page.find('.tariff-search-banner__toggle').click

        page.find('.tariff-search-banner .autocomplete__input').click

        page.find('.tariff-search-banner .autocomplete__input').set('gold')

        expect(page).to have_css('.tariff-search-banner .autocomplete__option')
        expect(page.find('.tariff-search-banner .autocomplete__option:first-of-type').text).to eq('gold')

        expect(page.find_all('.tariff-search-banner .autocomplete__option').length).to be > 1

        expect(page.find('.tariff-search-banner .autocomplete__option:first-of-type').text).to eq('gold')
        expect(page).to have_content('goldsmiths')

        page.find('.tariff-search-banner .autocomplete__option:first-of-type').click

        expect(page).to have_content('Search results for ‘gold’')
      end
    end
  end

  context 'when no result can be found' do
    it 'handles no results found' do
      VCR.use_cassette('search#gibberish') do
        visit browse_sections_path

        page.find('.tariff-search-banner__toggle').click

        page.find('.tariff-search-banner .autocomplete__input').click

        page.find('.tariff-search-banner .autocomplete__input').set('dsauidoasuiodsa')

        expect(page).to have_css('.tariff-search-banner .autocomplete__option')

        expect(page.find_all('.tariff-search-banner .autocomplete__option').length).to eq(1)
        expect(page.find('.tariff-search-banner .autocomplete__option:first-of-type').text).to eq('dsauidoasuiodsa')

        page.find('.tariff-search-banner .autocomplete__option:first-of-type').click

        expect(page).to have_content('Search results for ‘dsauidoasuiodsa’')
        expect(page).to have_content('There are no results matching your query.')
      end
    end
  end
end
