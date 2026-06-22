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

    context 'when a user is authenticated' do
      before do
        stub_authenticated_user(user)
        get :start
      end

      it 'assigns @continue_url to myott_path' do
        expect(assigns(:continue_url)).to eq(myott_path)
      end
    end

    context 'when a user is not authenticated' do
      before do
        stub_unauthenticated_user
        get :start, params: { return_to: '/subscriptions/mycommodities?as_of=2025-06-20' }
      end

      it 'assigns @continue_url to the identity base url' do
        expected_url = "#{URI.join(TradeTariffFrontend.identity_base_url, '/myott')}?return_to=%2Fsubscriptions%2Fmycommodities%3Fas_of%3D2025-06-20"
        expect(assigns(:continue_url)).to eq(expected_url)
      end
    end

    context 'when a user is not authenticated and the return URL is unsafe' do
      before do
        stub_unauthenticated_user
        get :start, params: { return_to: 'https://example.com/phishing' }
      end

      it 'assigns @continue_url to the identity base url without a return URL' do
        expected_url = URI.join(TradeTariffFrontend.identity_base_url, '/myott').to_s
        expect(assigns(:continue_url)).to eq(expected_url)
      end
    end

    context 'when a user is not authenticated and the return URL is protocol-relative' do
      before do
        stub_unauthenticated_user
        get :start, params: { return_to: '//example.com/phishing' }
      end

      it 'assigns @continue_url to the identity base url without a return URL' do
        expected_url = URI.join(TradeTariffFrontend.identity_base_url, '/myott').to_s
        expect(assigns(:continue_url)).to eq(expected_url)
      end
    end

    context 'when a user is not authenticated and the return URL only has the subscriptions prefix' do
      before do
        stub_unauthenticated_user
        get :start, params: { return_to: '/subscriptions.evil/mycommodities?as_of=2025-06-20' }
      end

      it 'assigns @continue_url to the identity base url without a return URL' do
        expected_url = URI.join(TradeTariffFrontend.identity_base_url, '/myott').to_s
        expect(assigns(:continue_url)).to eq(expected_url)
      end
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

      it { is_expected.not_to redirect_to myott_path }
      it { is_expected.to render_template(:invalid) }
    end
  end

  describe 'GET #index' do
    it_behaves_like 'a protected myott page', :index

    context 'when current_user is valid' do
      before do
        stub_authenticated_user(user)
      end

      context 'when return_to is a safe subscriptions path' do
        before do
          get :index, params: { return_to: '/subscriptions/mycommodities?as_of=2025-06-20' }
        end

        it { is_expected.to redirect_to('/subscriptions/mycommodities?as_of=2025-06-20') }
      end

      context 'when return_to is an unsafe absolute URL' do
        before do
          get :index, params: { return_to: 'https://example.com/phishing' }
        end

        it { is_expected.to respond_with(:success) }
      end

      context 'when return_to is a protocol-relative URL' do
        before do
          get :index, params: { return_to: '//example.com/phishing' }
        end

        it { is_expected.to respond_with(:success) }
      end

      context 'when return_to is the subscriptions index path' do
        before do
          get :index, params: { return_to: '/subscriptions' }
        end

        it { is_expected.to respond_with(:success) }
      end

      context 'when my_commodities is enabled' do
        let(:stop_press_subscription) { build(:subscription, :stop_press) }
        let(:my_commodities_subscription) { build(:subscription, :my_commodities) }

        before do
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
