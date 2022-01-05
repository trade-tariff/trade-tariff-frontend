require 'spec_helper'

RSpec.describe 'Search banner', js: true do
  before { allow(TradeTariffFrontend).to receive(:search_banner?).and_return true }

  context 'when hitting the autocomplete fields' do
    it 'fetches data from the server as we type' do
      VCR.use_cassette('geographical_areas#countries') do
        VCR.use_cassette('sections#index') do
          VCR.use_cassette('search#gold') do
            visit browse_sections_path

            page.find('.tariff-search-banner__toggle').click

            page.find('.tariff-search-banner .autocomplete__input').click

            page.find('.tariff-search-banner .autocomplete__input').set('gold')
            sleep 1

            expect(page.find('.tariff-search-banner .autocomplete__option--focused').text).to eq('gold')

            using_wait_time 1 do
              expect(page.find_all('.tariff-search-banner .autocomplete__option').length).to be > 1
            end

            expect(page.find('.tariff-search-banner .autocomplete__option--focused').text).to eq('gold')
            expect(page).to have_content('gold - gold coin')

            page.find('.tariff-search-banner .autocomplete__option--focused').click

            # trying to see if redirect done by JS needs some sleep to be caught up
            sleep 1

            expect(page).to have_content('Search results for ‘gold’')
          end
        end
      end
    end
  end

  context 'when no result can be found' do
    it 'handles no results found' do
      VCR.use_cassette('geographical_areas#countries') do
        VCR.use_cassette('sections#index') do
          VCR.use_cassette('search#gibberish') do
            visit browse_sections_path

            page.find('.tariff-search-banner__toggle').click

            page.find('.tariff-search-banner .autocomplete__input').click

            page.find('.tariff-search-banner .autocomplete__input').set('dsauidoasuiodsa')

            sleep 1

            expect(page.find_all('.tariff-search-banner .autocomplete__option').length).to eq(1)
            expect(page.find('.tariff-search-banner .autocomplete__option--focused').text).to eq('dsauidoasuiodsa')
            sleep 1

            page.find('.tariff-search-banner .autocomplete__option--focused').click

            # trying to see if redirect done by JS needs some sleep to be caught up
            sleep 1

            expect(page).to have_content('Search results for ‘dsauidoasuiodsa’')
            expect(page).to have_content('There are no results matching your query.')
          end
        end
      end
    end
  end
end
