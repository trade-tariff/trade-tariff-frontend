RSpec.describe DutyCalculator::Steps::FinalUseController, :user_session do
  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

  describe 'GET #show' do
    subject(:response) { get :show }

    it 'assigns the correct step' do
      response
      expect(assigns[:step]).to be_a(DutyCalculator::Steps::FinalUse)
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('final_use/show') }
  end

  describe 'POST #create' do
    subject(:response) { post :create, params: answers }

    let(:answers) do
      {
        duty_calculator_steps_final_use: final_use,
      }
    end

    context 'when the step answers are valid' do
      let(:final_use) { attributes_for(:duty_calculator_final_use, final_use: 'no') }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::FinalUse)
      end

      it { expect(response).to redirect_to(interstitial_path) }
      it { expect { response }.to change(user_session, :final_use).from(nil).to('no') }
    end

    context 'when the step answers are invalid' do
      let(:final_use) { attributes_for(:duty_calculator_final_use, final_use: '') }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::FinalUse)
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to render_template('final_use/show') }
      it { expect { response }.not_to change(user_session, :final_use).from(nil) }
    end
  end
end
