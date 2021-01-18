require 'spec_helper'

describe 'Search', js: true, vcr: {
  cassette_name: 'country_filtering',
  record: :new_episodes,
  match_requests_on: %i[query path],
} do
  it 'is possible to filter measures by country' do
    visit commodity_path('0101210000', as_of: '2019-03-05')

    sleep 2

    within '.govuk-tabs' do
      click_on 'Import'
    end

    expect(page).to have_select('import_search_country-select', selected: 'All countries')

    within '#import_edit_search' do
      page.find('#import_search_country').click

      fill_in 'import_search_country', with: 'United States of America'
      expect(page.find('#import_search_country').value).to eq('United States of America')

      sleep 2

      expect(page.find_all('.autocomplete__option').length).to eq(1)
      expect(page.find_all('.autocomplete__option')[0].text).to eq('United States of America (US)')

      page.find_all('.autocomplete__option')[0].click

      sleep 2

      expect(page.find('#import_search_country').value).to eq('United States of America (US)')
    end

    expect(page).to have_content('Measures for United States of America')

    page.find('.reset-country-picker', visible: true).click

    sleep 2
    expect(page.find('#import_search_country').value).to eq('All countries')
  end
end
