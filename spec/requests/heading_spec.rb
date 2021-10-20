require 'spec_helper'

RSpec.describe 'Heading page', type: :request do
  before do
    stub_const('MeasureConditionDialog::CONFIG_FILE_NAME', file_fixture('measure_condition_dialog_config.yaml'))

    allow(RulesOfOrigin::Scheme).to receive(:all).and_return([])
    TradeTariffFrontend::ServiceChooser.service_choice = nil
  end

  context 'when requesting as as HTML' do
    context 'with a declarable heading' do
      context 'without country filter' do
        it 'displays declarable related information' do
          VCR.use_cassette('headings#show_declarable') do
            visit heading_path('0501')

            expect(page).to have_content 'Importing from outside the UK is subject to a third country duty of 0.00 % unless subject to other measures.'
          end
        end
      end

      context 'with country filter' do
        it 'responds with 200' do
          VCR.use_cassette('headings#show_declarable') do
            visit heading_path('0501', country: 'ZW')

            expect(page.status_code).to eq(200)
          end
        end
      end
    end

    context 'with a regular heading' do
      before do
        VCR.use_cassette('geographical_areas#countries') do
          VCR.use_cassette('headings#show') do
            visit heading_path('0101')
          end
        end
      end

      it 'displays the link to all sections' do
        expect(page).to have_link 'All sections',
                                  href: '/sections'
      end

      it 'displays the section as a link' do
        expect(page).to have_link 'Section I: Live animals; animal products',
                                  href: '/sections/1'
      end

      it 'displays the chapter as a link' do
        expect(page).to have_link 'Live animals',
                                  href: '/chapters/01'
      end

      it 'displays the current header' do
        expect(page).to have_content 'Live horses, asses, mules and hinnies'
      end

      it 'displays the first level of children commodities' do
        expect(page).to have_content 'Horses'
      end

      it 'displays the leaf level of children commodities as a link' do
        expect(page).to have_link 'Pure-bred breeding animals'
      end
    end
  end

  context 'when requesting as JSON' do
    context 'when requested with json format' do
      before do
        VCR.use_cassette('headings#show_0101_api_json_format') do
          get '/headings/0101.json'
        end
      end

      let(:json) { JSON.parse(response.body) }

      it 'renders the correct item id' do
        expect(json['goods_nomenclature_item_id']).to eq '0101000000'
      end

      it 'renders direct API response' do
        expect(json['commodities']).to be_kind_of Array
      end
    end

    context 'when requested with json HTTP Accept header' do
      before do
        VCR.use_cassette('headings#show_0101_api_json_content_type') do
          get '/headings/0101', headers: { 'HTTP_ACCEPT' => 'application/json' }
        end
      end

      let(:json) { JSON.parse(response.body) }

      it 'renders the correct item id' do
        expect(json['goods_nomenclature_item_id']).to eq '0101000000'
      end

      it 'renders direct API response' do
        expect(json['commodities']).to be_kind_of Array
      end
    end
  end
end
