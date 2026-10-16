RSpec.describe DutyCalculator::Steps::CustomsValueController, :user_session do
  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

  describe 'GET #show' do
    subject(:response) { get :show }

    it 'assigns the correct step' do
      response
      expect(assigns[:step]).to be_a(DutyCalculator::Steps::CustomsValue)
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('customs_value/show') }

    context 'when rendering the standard journey' do
      render_views

      it { expect(response.body).to include('What is the value of this import?') }
      it { expect(response.body).to include('Shipping cost (optional)') }
      it { expect(response.body).to include('href="/howto/valuation"') }
      it { expect(response.body).to include('href="/duty-calculator/0702000007/import-details"') }
    end
  end

  describe 'POST #create' do
    subject(:response) { post :create, params: answers }

    let(:answers) do
      {
        duty_calculator_steps_customs_value: customs_value,
      }
    end

    context 'when the step answers are valid' do
      let(:customs_value) { attributes_for(:duty_calculator_customs_value, monetary_value: '1500') }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::CustomsValue)
      end

      it { expect(response).to redirect_to(measure_amount_path) }
      it { expect { response }.to change(user_session, :monetary_value).from(nil).to('1500') }
    end

    context 'when the step answers are invalid' do
      let(:customs_value) { attributes_for(:duty_calculator_customs_value, monetary_value: '-1500') }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::CustomsValue)
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to render_template('customs_value/show') }
      it { expect { response }.not_to change(user_session, :customs_value).from(nil) }
    end
  end

  describe 'returning to Check your answers' do
    subject(:response) { post :create, params: { duty_calculator_steps_customs_value: { monetary_value: '1500' } } }

    let(:user_session) do
      build(:duty_calculator_user_session, :with_commodity_information, vat:, return_to_confirm: true)
    end
    let(:vat) { 'VATZ' }
    let(:commodity) do
      build(
        :duty_calculator_commodity,
        applicable_measure_units: {},
        applicable_additional_codes: {},
        applicable_vat_options: {
          'VATZ' => 'VAT zero rate (0.0)',
          'VAT' => 'Value added tax (20.0)',
        },
        import_measures: [],
      )
    end

    before do
      allow(DutyCalculator::Api::Commodity).to receive(:build).and_return(commodity)
    end

    context 'when the VAT answer is still valid' do
      it { expect(response).to redirect_to(confirm_path) }
    end

    context 'when the VAT answer must be given again' do
      let(:vat) { nil }

      it { expect(response).to redirect_to(vat_path) }
    end
  end
end
