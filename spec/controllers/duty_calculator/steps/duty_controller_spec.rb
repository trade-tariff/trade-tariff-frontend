RSpec.describe DutyCalculator::Steps::DutyController, :user_session do
  before do
    allow(DutyCalculator::DutyCalculator).to receive(:new).and_return(duty_calculator)
    allow(DutyCalculator::Api::MonetaryExchangeRate).to receive(:for).with('GBP').and_call_original
  end

  let(:user_session) { build(:duty_calculator_user_session, import_destination: 'XI', commodity_code: '0103921100', country_of_origin: 'AF') }
  let(:duty_calculator) { instance_double(DutyCalculator::DutyCalculator, options: []) }

  describe 'GET #show' do
    subject(:response) { get :show }

    it 'assigns the correct rules of origin' do
      response
      expect(assigns[:rules_of_origin_schemes].first).to be_a(DutyCalculator::Api::RulesOfOriginScheme)
    end

    it 'assigns the correct duty options' do
      response
      expect(assigns[:duty_options]).to eq([])
    end

    it 'assigns the correct exchange rate options' do
      response
      expect(assigns[:gbp_to_eur_exchange_rate]).to eq(0.8571)
    end

    it 'calls the ExchangeRate api' do
      response
      expect(DutyCalculator::Api::MonetaryExchangeRate).to have_received(:for)
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('steps/duty/show') }

    it 'calls the DutyCalculator' do
      response
      expect(DutyCalculator::DutyCalculator).to have_received(:new)
    end

    context 'when on ROW to NI' do
      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, :deltas_applicable, commodity_code: '0103921100') }
      let(:row_to_ni_duty_calculator) { instance_double(DutyCalculator::RowToNiDutyCalculator, options: []) }

      it 'calls the RowToNiDutyCalculator' do
        allow(DutyCalculator::RowToNiDutyCalculator).to receive(:new).and_return(row_to_ni_duty_calculator)

        response

        expect(DutyCalculator::RowToNiDutyCalculator).to have_received(:new)
      end
    end
  end

  context 'when the duty calculator UX improvements are switched on' do
    render_views

    subject(:response) { get :show }

    let(:user_session) do
      build(
        :duty_calculator_user_session,
        commodity_code: '0103921100',
        import_date: '2026-09-01',
        import_destination: 'UK',
        country_of_origin: 'AR',
        customs_value: { 'monetary_value' => '10000', 'shipping_cost' => '180', 'insurance_cost' => '20' },
        vat: 'VAT',
        vat_assumed:,
      )
    end
    let(:vat_assumed) { false }
    let(:rows) { [['Valuation for import', 'Value of goods + freight + insurance costs', '£10,200.00'], ['<strong>Duty Total</strong>'.html_safe, nil, '£3,508.80']] }
    let(:duty_options) do
      [
        DutyCalculator::DutyOptionResult.new(type: 'third_country_tariff', category: :third_country_tariff, footnote: '', values: rows, value: 1224, source: 'uk').tap do |option|
          option.duty_total = 1224
          option.footnote_suffix = '<p class="govuk-body">Northern Ireland explanation</p>'.html_safe
        end,
        DutyCalculator::DutyOptionResult.new(type: 'tariff_preference', category: :tariff_preference, footnote: '', values: rows, value: 0, source: 'uk', geographical_area_description: 'Argentina').tap { |option| option.duty_total = 0 },
      ]
    end
    let(:duty_calculator) { instance_double(DutyCalculator::DutyCalculator, options: duty_options) }

    before do
      allow(TradeTariffFrontend).to receive(:duty_calculator_ux_improvements?).and_return(true)
      allow(DutyCalculator::Api::GeographicalArea).to receive(:build)
        .with(:uk, 'AR')
        .and_return(DutyCalculator::Api::GeographicalArea.new(geographical_area_id: 'AR', description: 'Argentina'))
    end

    it { expect(response.body).to include('Import cost estimate') }
    it { expect(response.body).to include('Estimated duty and VAT using standard duty') }
    it { expect(response.body).to include('Third-country duty') }
    it { expect(response.body).to include('£1,224.00') }
    it { expect(response.body).to include('Tariff preference rate') }
    it { expect(response.body).to include('Tariff preference - Argentina') }
    it { expect(response.body).to include('Show calculations') }
    it { expect(response.body).to include('Northern Ireland explanation') }
    it { expect(response.body).to include('£3,508.80') }
    it { expect(response.body).to include('Details used for this estimate') }
    it { expect(response.body).to include('1 September 2026') }
    it { expect(response.body).to include('£10,200.00') }
    it { expect(response.body).to include('Next steps') }
    it { expect(response.body).to include('Help us improve this service') }
    it { expect(response.body).to include("href=\"#{confirm_path}\"") }
    it { expect(response.body).not_to include('<details class="govuk-details duty-estimate-calculations" open') }
    it { expect(response.body).not_to include('generally standard-rate VAT') }

    context 'when the VAT rate was assumed' do
      let(:vat_assumed) { true }

      it { expect(response.body).to include('If you cannot provide details, generally standard-rate VAT (20%) applies.') }
    end
  end

  describe '#title' do
    before do
      controller.instance_variable_set('@duty_options', duty_options)
    end

    context 'when there are duty options available' do
      let(:duty_options) { build_list(:duty_calculator_duty_option_result, 1) }

      it { expect(controller.helpers.title).to eq('Import duty calculation - Online Tariff Duty calculator') }
    end

    context 'when there are no duty options available' do
      let(:duty_options) { nil }

      it { expect(controller.helpers.title).to eq('There is no import duty to pay - Online Tariff Duty calculator') }
    end
  end
end
