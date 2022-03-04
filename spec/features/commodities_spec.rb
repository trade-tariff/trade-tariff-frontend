require 'spec_helper'

RSpec.describe 'Commodity show page', vcr: { cassette_name: 'geographical_areas#1013' }, js: true do
  before do
    stub_const('MeasureConditionDialog::CONFIG_FILE_NAME', file_fixture('measure_condition_dialog_config.yaml'))

    TradeTariffFrontend::ServiceChooser.service_choice = 'xi'

    VCR.use_cassette('headings#show_0201', record: :new_episodes) do
      visit commodity_path('0201100021', day: 31, month: 5, year: 2018)
    end

    VCR.use_cassette('commodities#show_0201100021_legal_base_visible_no_env') do
      VCR.use_cassette('headings#show_0201') do
        visit commodity_path('0201100021', day: 21, month: 2, year: 2019, no_env: true)
      end
    end
  end

  it 'displays the legal base column' do
    expect(page).to have_content('Legal base')
  end

  it 'displays the current regulations' do
    expect(page).to have_content('R2204/99')
  end

  context 'when clicking tabs' do
    it '*import* tab is present' do
      expect(page).to have_selector('#import.govuk-tabs__panel', visible: :visible)
    end

    describe 'switch tabs' do
      before do
        within '.govuk-tabs' do
          click_on 'Export'
        end
      end

      it '*export* tab is shown' do
        expect(page).to have_selector('#export.govuk-tabs__panel', visible: :visible)
      end
    end
  end

  context 'when clicking popups' do
    before do
      # rubocop:disable RSpec/ExpectInHook
      expect(page).not_to have_selector('#popup .info-content', visible: :visible) # ensure popup is hidden
      # rubocop:enable RSpec/ExpectInHook

      within '#measure-3522474' do
        click_on 'Conditions'
      end
    end

    it 'displays the popup' do
      expect(page).to have_selector('#popup .info-content', visible: :visible)
    end

    it 'displays the popup content' do
      expect(page).to have_content('Import control of organic products')
    end
  end
end
