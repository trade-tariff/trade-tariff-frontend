require 'spec_helper'

RSpec.describe 'Commodity show page', :js, vcr: { cassette_name: 'geographical_areas#1013' } do
  before do
    stub_const('MeasureConditionDialog::CONFIG_FILE_NAME', file_fixture('measure_condition_dialog_config.yaml'))
    allow(DeclarableUnitService).to receive(:new).and_return(instance_double(DeclarableUnitService, call: ''))
    allow(RulesOfOrigin::Scheme).to receive(:all).and_return build_list(:rules_of_origin_scheme, 1)

    TradeTariffFrontend::ServiceChooser.service_choice = 'xi'

    VCR.use_cassette('commodities#0201100021') do
      visit commodity_path(
        '0201100021',
        day: 11,
        month: 2,
        year: 2025,
        no_env: true,
      )
    end
  end

  it 'displays the legal base column' do
    expect(page).to have_content('Legal base')
  end

  it 'displays the current regulations' do
    expect(page).to have_content('R2204/99')
  end

  context 'when clicking tabs' do
    before do
      within '.govuk-tabs' do
        click_on 'Export'
      end
    end

    it '*export* tab is shown' do
      expect(page).to have_selector('#export.govuk-tabs__panel', visible: :visible)
    end
  end

  context 'when clicking popups' do
    before do
      # rubocop:disable RSpec/ExpectInHook
      expect(page).not_to have_selector('#modal .info-content', visible: :visible) # ensure popup is hidden
      # rubocop:enable RSpec/ExpectInHook

      within '#measure-3977333' do
        click_on 'Conditions'
      end
    end

    it 'displays the popup' do
      expect(page).to have_selector('#modal .info-content', visible: :visible)
    end

    it 'displays the popup content' do
      expect(page).to have_content('The proof of origin indicates that the production')
    end
  end
end
