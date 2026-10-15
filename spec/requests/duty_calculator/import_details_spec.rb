require 'spec_helper'

RSpec.describe 'Duty calculator import details', :user_session, type: :request do
  let(:user_session) { build(:duty_calculator_user_session, commodity_source: nil) }
  let(:commodity_code) { '0702000007' }
  let(:path) { "/duty-calculator/#{commodity_code}/import-details" }
  let(:destination_radios) { page.css('input[type="radio"][name="duty_calculator_steps_import_details[import_destination]"]') }
  let(:origin_options) { page.css('#duty-calculator-steps-import-details-country-of-origin-field option').map { |option| option['value'] } }

  before do
    allow(Commodity).to receive(:find).and_return(DutyCalculator::Api::Commodity.new(attributes_for(:commodity, goods_nomenclature_item_id: commodity_code)))
  end

  describe 'GET import details' do
    include_context 'with UK service'

    # The request is made inside the example, after the service of the nested contexts is set.
    let(:page) do
      get path
      Nokogiri::HTML(response.body)
    end

    it 'does not select a part of the UK' do
      expect(destination_radios.map { |radio| radio['checked'] }).to all(be_nil)
    end

    it 'lists the countries of the UK service' do
      expect(origin_options).to include('XI')
    end

    it 'links back to the commodity page' do
      expect(page.css('a.govuk-back-link').first['href']).to eq("/commodities/#{commodity_code}")
    end

    context 'when the trader came from Check your answers' do
      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, return_to_confirm: true) }

      it 'links back to the commodity page' do
        expect(page.css('a.govuk-back-link').first['href']).to eq("/commodities/#{commodity_code}")
      end
    end

    context 'when the trader is on the Northern Ireland service' do
      include_context 'with XI service'

      it { expect(origin_options).to include('GB') }
      it { expect(origin_options).not_to include('XI') }
    end
  end

  describe 'POST import details without a part of the UK' do
    include_context 'with XI service'

    let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }
    let(:page) { Nokogiri::HTML(response.body) }

    before do
      post path, params: {
        duty_calculator_steps_import_details: {
          'import_date(3i)' => '1',
          'import_date(2i)' => '9',
          'import_date(1i)' => '2026',
          'import_destination' => '',
          'country_of_origin' => 'GB',
        },
      }
    end

    it 'asks for a part of the UK' do
      expect(page.css('.govuk-error-summary').text).to include('Select a destination')
    end

    it 'does not select a part of the UK' do
      expect(destination_radios.map { |radio| radio['checked'] }).to all(be_nil)
    end

    it { expect(origin_options).to include('GB') }
    it { expect(origin_options).not_to include('XI') }

    it 'keeps the chosen country' do
      expect(page.css('#duty-calculator-steps-import-details-country-of-origin-field option[selected]').first['value']).to eq('GB')
    end
  end
end
