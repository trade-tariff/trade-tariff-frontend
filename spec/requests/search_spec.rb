require 'spec_helper'

RSpec.describe 'Search page', type: :request do
  shared_examples 'search results' do
    before do
      stub_const('MeasureConditionDialog::CONFIG_FILE_NAME', file_fixture('measure_condition_dialog_config.yaml'))
      allow(Section).to receive(:all).and_return([])
    end

    context 'when exact match' do
      it 'redirects user to exact match page' do
        VCR.use_cassette('searching#exact_match') do
          visit public_send(search_path, q: '0101210000')

          within('#new_search') do
            click_button 'Search'
          end

          expect(page.text).to include('Pure-bred breeding animals',
                                       'The commodity code for importing is 0101210000.')
        end
      end
    end

    context 'when search results page is finished (fuzzy match)' do
      it 'returns result list' do
        VCR.use_cassette('searching#fuzzy') do
          visit public_send(search_path, q: 'horses')

          within('#new_search') do
            # fill_in 'q', with: 'horses'
            click_button 'Search'
          end

          expect(page).to have_content 'Other results containing the term ‘horses’'
        end
      end
    end

    context 'when no results found' do
      it 'displays no results message' do
        VCR.use_cassette('searching#no_results') do
          visit public_send(search_path, q: '!!!!!!!!!!!!')

          within('#new_search') do
            click_button 'Search'
          end

          expect(page).to have_content 'There are no results matching your query'
        end
      end
    end

    context 'when duplicate results and search results page is finished' do
      it 'Display section when matching' do
        VCR.use_cassette('searching#exact_match') do
          visit public_send(search_path, q: 'synonym 1')
          within('#new_search') do
            click_button 'Search'
          end
          expect(page).to have_content('Section I')
        end
      end
    end
  end

  context 'with old sections page' do
    before do
      allow(TradeTariffFrontend).to receive(:updated_navigation?).and_return false
    end

    let(:search_path) { :sections_path }

    it_behaves_like 'search results'
  end

  context 'with new separate browse and find commodity pages' do
    let(:search_path) { :find_commodity_path }

    it_behaves_like 'search results'
  end
end
