RSpec.describe DutyCalculator::Steps::InterstitialController, :user_session do
  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

  describe 'GET #show' do
    subject(:response) { get :show }

    it 'assigns the correct step' do
      response
      expect(assigns[:step]).to be_a(DutyCalculator::Steps::Interstitial)
    end

    it { expect(response).to have_http_status(:ok) }
    it { expect(response).to render_template('interstitial/show') }
  end

  describe '#title' do
    context 'when the route is GB to NI' do
      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information, :with_possible_duty_route_into_ni) }

      it { expect(controller.helpers.title).to eq('Duties apply to this import - Online Tariff Duty calculator') }
    end

    context 'when the route is not GB to NI' do
      let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

      it { expect(controller.helpers.title).to eq('EU duties apply to this import - Online Tariff Duty calculator') }
    end
  end
end
