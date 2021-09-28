require 'spec_helper'

describe 'Search page', type: :request do
  describe 'search results' do
    before do
      allow(Section).to receive(:all).and_return([])
    end

    context 'exact match' do
      it 'redirects user to exact match page' do
        VCR.use_cassette('tariff_updates#index') do
          visit sections_path(q: '0101210000')

          within('#new_search') do
            # fill_in 'q', with: '0101210000'
            # select2('0101210000', css: ".js-commodity-picker-select")
            click_button 'Search'
          end

          expect(page).to have_content 'Pure-bred breeding animals'
          expect(page).to have_content 'The commodity code for importing is 0101210000.'
        end
      end
    end

    context 'fuzzy match - when search results page is finished' do
      it 'returns result list' do
        VCR.use_cassette('search_fuzzy_horses') do
          visit sections_path(q: 'horses')

          within('#new_search') do
            # fill_in 'q', with: 'horses'
            click_button 'Search'
          end

          expect(page).to have_content 'Other results containing the term ‘horses’'
        end
      end
    end

    context 'no results found' do
      it 'displays no results message' do
        VCR.use_cassette('search_no_results') do
          visit sections_path(q: '!!!!!!!!!!!!')

          within('#new_search') do
            # fill_in 'q', with: " !such string should not exist in the database! "
            click_button 'Search'
          end

          expect(page).to have_content 'There are no results matching your query'
        end
      end
    end

    context 'duplicate results - when search results page is finished' do
      it 'Display section when matching' do
        VCR.use_cassette('tariff_updates#index') do
          visit sections_path(q: 'synonym 1')
          within('#new_search') do
            # fill_in "q", with: "synonym 1"
            click_button 'Search'
          end
          save_and_open_page
          expect(page).to have_content('Section I')
        end
      end
    end
  end
end
