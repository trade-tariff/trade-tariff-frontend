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
