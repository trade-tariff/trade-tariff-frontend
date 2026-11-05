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

    it 'does not store an oversized search results path in the session', :aggregate_failures do
      get path, params: {
        duty_calculator: 'true',
        journey: 'interactive_search',
        search_results_path: "/search?q=#{'a' * 5_000}",
      }

      expect(response).to have_http_status(:ok)
      expect(user_session.duty_calculator_search_results_path).to be_nil
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

    context 'when the trader changes import details from Check your answers' do
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_commodity_information,
          :with_import_date,
          :with_import_destination,
          :with_country_of_origin,
          commodity_code:,
          import_destination: 'UK',
          country_of_origin: 'AR',
          duty_calculator_journey: true,
        )
      end

      it 'keeps the calculator journey when opening import details', :aggregate_failures do
        allow(DutyCalculator::Api::GeographicalArea).to receive(:build).with(:uk, 'AR').and_return(
          DutyCalculator::Api::GeographicalArea.new(geographical_area_id: 'AR', description: 'Argentina'),
        )

        get confirm_path
        change_link = Capybara.string(response.body).find_link('Change import details')
        expect(change_link[:href]).to include('duty_calculator=true')

        get change_link[:href]

        expect(Capybara.string(response.body)).to have_field('duty_calculator', type: 'hidden', with: 'true')
      end

      context 'when the session is for an existing commodity-page journey' do
        let(:user_session) do
          super().tap { |session| session.duty_calculator_journey = false }
        end

        it 'does not mark import details as a homepage calculator journey' do
          allow(DutyCalculator::Api::GeographicalArea).to receive(:build).with(:uk, 'AR').and_return(
            DutyCalculator::Api::GeographicalArea.new(geographical_area_id: 'AR', description: 'Argentina'),
          )

          get confirm_path
          change_link = Capybara.string(response.body).find_link('Change import details')

          expect(Rack::Utils.parse_query(URI(change_link[:href]).query)).not_to have_key('duty_calculator')
        end
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
