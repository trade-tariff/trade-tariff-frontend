require 'spec_helper'

RSpec.describe 'Search page', type: :request do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  before do
    stub_const('MeasureConditionDialog::CONFIG_FILE_NAME', file_fixture('measure_condition_dialog_config.yaml'))
    allow(Section).to receive(:all).and_return([])
    allow(GeographicalArea).to receive(:all).and_return([])
    allow(RulesOfOrigin::Scheme).to receive(:all).and_return([])
  end

  context 'when exact match' do
    it 'redirects user to exact match page' do
      VCR.use_cassette('searching#exact_match') do
        visit find_commodity_path(q: '0101210000')

        within('#new_search') do
          click_button 'Search'
        end

        expect(page.text).to include('Pure-bred breeding animals')
      end
    end
  end

  context 'when search results page is finished (fuzzy match)' do
    it 'returns result list' do
      VCR.use_cassette('searching#fuzzy') do
        visit find_commodity_path(q: 'horses')

        within('#new_search') do
          click_button 'Search'
        end

        expect(page).to have_content 'Other results containing the term ‘horses’'
      end
    end
  end

  context 'when no results found' do
    it 'displays no results message' do
      VCR.use_cassette('searching#no_results') do
        visit find_commodity_path(q: '!!!!!!!!!!!!')

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
        visit find_commodity_path(q: 'synonym 1')
        within('#new_search') do
          click_button 'Search'
        end
        expect(page).to have_content('Section I')
      end
    end
  end
end
