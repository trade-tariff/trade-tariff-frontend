require 'spec_helper'

RSpec.describe 'Duty calculator import details session', type: :request do
  include_context 'with UK service'

  let(:commodity_code) { '0204100010' }
  let(:path) { import_details_path(commodity_code:) }
  let(:back_path) { import_details_path(commodity_code:, day: 16, month: 10, year: 2026) }
  let(:page) { Capybara.string(response.body) }
  let(:answers) do
    {
      duty_calculator_steps_import_details: {
        'import_destination' => 'UK',
        'country_of_origin' => 'AG',
        'import_date(3i)' => '16',
        'import_date(2i)' => '10',
        'import_date(1i)' => '2026',
      },
    }
  end

  before do
    allow(Commodity).to receive(:find).and_return(
      DutyCalculator::Api::Commodity.new(attributes_for(:commodity, goods_nomenclature_item_id: commodity_code)),
    )
    allow(DutyCalculator::Api::GeographicalArea).to receive(:list_countries).and_return(
      [build(:duty_calculator_geographical_area, geographical_area_id: 'AG', description: 'Antigua and Barbuda')],
    )
  end

  shared_examples 'a continuing import journey' do
    it 'continues with the submitted commodity', :aggregate_failures do
      post path, params: answers

      expect(response).to redirect_to(customs_value_path)
      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(page).to have_css('h1', text: 'What is the value of this import?')
      expect(page).to have_link('Back', href: back_path)
    end
  end

  context 'when starting a fresh journey' do
    before { get path }

    include_examples 'a continuing import journey'
  end

  context 'without calculator session context' do
    include_examples 'a continuing import journey'
  end

  context 'when another commodity is in the session' do
    before { get import_details_path(commodity_code: '0702000007') }

    include_examples 'a continuing import journey'
  end
end
