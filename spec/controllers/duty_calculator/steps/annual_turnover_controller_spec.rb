RSpec.describe DutyCalculator::Steps::AnnualTurnoverController, :user_session do
  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

  describe 'GET #show' do
    subject(:response) { get :show }

    it 'assigns the correct step' do
      response
      expect(assigns[:step]).to be_a(DutyCalculator::Steps::AnnualTurnover)
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('annual_turnover/show') }
  end

  describe 'POST #create' do
    subject(:response) { post :create, params: answers }

    let(:answers) do
      {
        duty_calculator_steps_annual_turnover: annual_turnover,
      }
    end

    context 'when the step answers are valid' do
      let(:annual_turnover) { attributes_for(:duty_calculator_annual_turnover, annual_turnover: 'no') }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::AnnualTurnover)
      end

      it { expect(response).to redirect_to(planned_processing_path) }
      it { expect { response }.to change(user_session, :annual_turnover).from(nil).to('no') }
    end

    context 'when the step answers are invalid' do
      let(:annual_turnover) { attributes_for(:duty_calculator_annual_turnover, annual_turnover: '') }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::AnnualTurnover)
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to render_template('annual_turnover/show') }
      it { expect { response }.not_to change(user_session, :annual_turnover).from(nil) }
    end
  end
end
