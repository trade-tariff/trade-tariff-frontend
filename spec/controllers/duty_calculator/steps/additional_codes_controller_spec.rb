RSpec.describe DutyCalculator::Steps::AdditionalCodesController, :user_session do
  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

  describe 'GET #show' do
    subject(:response) { get :show, params: { measure_type_id: '105' } }

    it 'assigns the correct step' do
      response
      expect(assigns[:step]).to be_a(DutyCalculator::Steps::AdditionalCode)
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('additional_codes/show') }
  end

  describe 'POST #create' do
    subject(:response) do
      post :create, params: { measure_type_id: '105' }.merge(answers)
    end

    let(:answers) do
      {
        duty_calculator_steps_additional_code: {
          additional_code_uk:,
          additional_code_xi:,
        },
      }
    end

    context 'when the step answers are valid' do
      let(:additional_code_uk) { '2300' }
      let(:additional_code_xi) { '2600' }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::AdditionalCode)
      end

      it { expect { response }.to change(user_session, :additional_code_uk).from({}).to('105' => '2300') }
      it { expect(response).to redirect_to(excise_path('306')) }
    end

    context 'when the step answers are invalid' do
      let(:additional_code_uk) { '' }
      let(:additional_code_xi) { '' }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::AdditionalCode)
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to render_template('additional_codes/show') }
      it { expect { response }.not_to change(user_session, :additional_code_uk).from({}) }
    end
  end
end
