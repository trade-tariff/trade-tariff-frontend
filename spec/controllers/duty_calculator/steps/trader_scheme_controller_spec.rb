RSpec.describe DutyCalculator::Steps::TraderSchemeController, :user_session do
  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

  describe 'GET #show' do
    subject(:response) { get :show }

    it 'assigns the correct step' do
      response
      expect(assigns[:step]).to be_a(DutyCalculator::Steps::TraderScheme)
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('trader_scheme/show') }
  end

  describe 'POST #create' do
    subject(:response) { post :create, params: answers }

    let(:answers) do
      {
        duty_calculator_steps_trader_scheme: trader_scheme,
      }
    end

    context 'when the step answers are valid' do
      let(:trader_scheme) { attributes_for(:duty_calculator_trader_scheme, trader_scheme: 'no') }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::TraderScheme)
      end

      it { expect(response).to redirect_to(interstitial_path) }
      it { expect { response }.to change(user_session, :trader_scheme).from(nil).to('no') }
    end

    context 'when the step answers are invalid' do
      let(:trader_scheme) { attributes_for(:duty_calculator_trader_scheme, trader_scheme: '') }

      it 'assigns the correct step' do
        response
        expect(assigns[:step]).to be_a(DutyCalculator::Steps::TraderScheme)
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to render_template('trader_scheme/show') }
      it { expect { response }.not_to change(user_session, :trader_scheme).from(nil) }
    end
  end
end
