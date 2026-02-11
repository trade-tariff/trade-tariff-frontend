RSpec.describe Myott::SubscriptionsController, type: :controller do
  include MyottAuthenticationHelpers

  include_context 'with cached chapters'

  let(:user) { build(:user, chapter_ids: '') }

  describe 'GET #start' do
    it 'does not authenticate the user' do
      allow(controller).to receive(:authenticate)

      get :start
      expect(controller).not_to have_received(:authenticate)
    end
  end

  describe 'GET #invalid' do
    it 'does not authenticate the user' do
      allow(controller).to receive(:authenticate)

      get :invalid
      expect(controller).not_to have_received(:authenticate)
    end

    context 'when a user does exist' do
      before do
        stub_authenticated_user(user)
        get :invalid
      end

      it { is_expected.to redirect_to myott_path }
    end

    context 'when a user does not exist' do
      before do
        stub_unauthenticated_user
        get :invalid
      end

      it { is_expected.not_to redirect_to myott_invalid_path }
    end
  end

  describe 'GET #index' do
    it_behaves_like 'a protected myott page', :index

    context 'when current_user is valid' do
      before do
        stub_authenticated_user(user)
      end

      context 'when my_commodities is not enabled' do
        before do
          allow(TradeTariffFrontend).to receive(:my_commodities?).and_return(false)
          get :index
        end

        it 'redirects to stop press' do
          expect(response).to redirect_to(myott_stop_press_path)
        end
      end

      context 'when my_commodities is enabled' do
        let(:stop_press_subscription) { build(:subscription, :stop_press) }
        let(:my_commodities_subscription) { build(:subscription, :my_commodities) }

        before do
          allow(TradeTariffFrontend).to receive(:my_commodities?).and_return(true)
          stub_current_subscription('stop_press', stop_press_subscription)
          stub_current_subscription('my_commodities', my_commodities_subscription)
          get :index
        end

        it { is_expected.to respond_with(:success) }

        it 'assigns stop_press subscription' do
          expect(assigns(:stop_press)).to eq(stop_press_subscription)
        end

        it 'assigns my_commodities subscription' do
          expect(assigns(:my_commodities)).to eq(my_commodities_subscription)
        end
      end
    end
  end
end
