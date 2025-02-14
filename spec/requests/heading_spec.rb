require 'spec_helper'

RSpec.describe 'Heading page', type: :request do
  before do
    stub_const('MeasureConditionDialog::CONFIG_FILE_NAME', file_fixture('measure_condition_dialog_config.yaml'))

    allow(GeographicalArea).to receive(:find).with('ZW').and_return(build(:geographical_area, id: 'ZW', description: 'Zimbabwe'))

    allow(RulesOfOrigin::Scheme).to receive(:for_heading_and_country).and_return([])
    TradeTariffFrontend::ServiceChooser.service_choice = nil
  end

  context 'when requesting as as HTML' do
    context 'with a regular heading' do
      before do
        VCR.use_cassette('geographical_areas#countries') do
          VCR.use_cassette('headings#show') do
            visit heading_path('0101')
          end
        end
      end

      it 'displays the link to find commodity' do
        expect(page).to have_link 'Search',
                                  href: '/find_commodity'
      end

      it 'displays the section as a link' do
        expect(page).to have_link 'Section I',
                                  href: '/sections/1'
      end

      it 'displays the chapter name as a link' do
        expect(page).to have_link 'Chapter 01',
                                  href: '/chapters/01'
      end

      it 'displays the current header' do
        expect(page).to have_content 'Live horses, asses, mules and hinnies'
      end

      it 'displays the leaf level of children commodities as a link' do
        expect(page).to have_link 'Pure-bred breeding animals'
      end
    end
  end
end
