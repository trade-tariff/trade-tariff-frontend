RSpec.describe Myott::MyottController, type: :controller do
  include MyottAuthenticationHelpers

  let(:return_key) { :myott_return_url }

  describe '#current_user' do
    let(:user) { build(:user) }
    let(:id_token) { 'encrypted_token' }
    let(:decrypted_token) { 'decrypted_token' }

    before do
      allow(controller).to receive(:cookies).and_return(id_token: id_token)
      allow(User).to receive(:find).and_return(user)
    end

    it 'returns the current user' do
      result = controller.send(:current_user)
      expect(result).to eq(user)
    end
  end

  describe '#current_subscription' do
    let(:subscription) { build(:subscription) }
    let(:subscription_type) { 'my_commodities' }

    context 'when a subscription is found' do
      before do
        allow(controller).to receive(:current_user).and_return(build(:user))
        allow(controller).to receive(:get_subscription).with(subscription_type).and_return(subscription)
      end

      it 'returns the current subscription' do
        result = controller.send(:current_subscription, subscription_type)
        expect(result).to eq(subscription)
      end
    end

    context 'when a subscription is not found' do
      before do
        allow(controller).to receive(:current_user).and_return(build(:user))
        allow(controller).to receive(:get_subscription).with(subscription_type).and_return(nil)
      end

      it 'returns nil' do
        result = controller.send(:current_subscription, subscription_type)
        expect(result).to be_nil
      end
    end
  end

  describe '#get_subscription' do
    let(:subscription) { build(:subscription) }
    let(:subscription_type) { 'my_commodities' }

    before do
      allow(controller).to receive(:cookies).and_return(id_token: 'token123')
      allow(User).to receive(:find).and_return({ subscriptions: user_subscription_hash })
      allow(Subscription).to receive(:find).with(subscription.uuid, 'token123')
                                          .and_return(subscription)
    end

    context 'when the user has an active subscription' do
      let(:user_subscription_hash) do
        [{
          'subscription_type' => subscription_type,
          'id' => subscription.uuid,
          'active' => true,
        }]
      end

      it 'returns the subscription for the matching subscription_type' do
        result = controller.send(:get_subscription, subscription_type)
        expect(result).to eq(subscription)
      end
    end

    context 'when the user does not have an active subscription' do
      let(:user_subscription_hash) do
        [{
          'subscription_type' => subscription_type,
          'id' => subscription.uuid,
          'active' => false,
        }]
      end

      it 'returns nil' do
        result = controller.send(:get_subscription, subscription_type)
        expect(result).to be_nil
      end
    end
  end

  describe '#authenticate' do
    before do
      allow(controller).to receive(:redirect_to)
    end

    context 'when current_user is nil' do
      let(:request_fullpath) { '/subscriptions/mycommodities?as_of=2025-06-20' }

      before do
        allow(controller).to receive(:current_user).and_return(nil)
        allow(controller.request).to receive(:fullpath).and_return(request_fullpath)
      end

      it 'redirects to the start page' do
        controller.send(:authenticate)

        expect(controller).to have_received(:redirect_to).with(myott_start_path(return_to: request_fullpath))
      end
    end

    context 'when current_user exists and myott_return_url is in session' do
      let(:user) { build(:user) }
      let(:return_url) { '/subscriptions/mycommodities?as_of=2025-06-20' }

      before do
        allow(controller).to receive(:current_user).and_return(user)
        controller.session[return_key] = return_url
      end

      it 'does not redirect to the stored return URL' do
        controller.send(:authenticate)

        expect(controller).not_to have_received(:redirect_to)
      end

      it 'leaves the stored return URL in session' do
        controller.send(:authenticate)

        expect(controller.session[return_key]).to eq(return_url)
      end
    end

    context 'when current_user exists and no myott_return_url is in session' do
      let(:user) { build(:user) }

      before do
        allow(controller).to receive(:current_user).and_return(user)
        controller.session[return_key] = nil
      end

      it 'does not redirect' do
        controller.send(:authenticate)

        expect(controller).not_to have_received(:redirect_to)
      end
    end
  end

  describe '#handle_authentication_error' do
    let(:identity_base_url) { 'https://auth.example.com' }
    let(:request_fullpath) { '/subscriptions/mycommodities?as_of=2025-06-20' }
    let(:error) { AuthenticationError.new('Authentication failed', reason: error_reason) }

    before do
      allow(controller.request).to receive(:fullpath).and_return(request_fullpath)
      allow(TradeTariffFrontend).to receive(:identity_base_url).and_return(identity_base_url)
      allow(controller).to receive(:redirect_to)
      allow(controller).to receive(:clear_authentication_cookies)
    end

    context 'when error requires clearing cookies' do
      let(:error_reason) { 'invalid_token' }

      it 'clears authentication cookies' do
        controller.send(:handle_authentication_error, error)

        expect(controller).to have_received(:clear_authentication_cookies)
      end

      it 'redirects to identity service with the current URL as return_to' do
        controller.send(:handle_authentication_error, error)

        expect(controller).to have_received(:redirect_to)
          .with('https://auth.example.com/myott?return_to=%2Fsubscriptions%2Fmycommodities%3Fas_of%3D2025-06-20', allow_other_host: true)
      end
    end

    context 'when error does not require clearing cookies' do
      let(:error_reason) { 'expired' }

      it 'does not clear authentication cookies' do
        controller.send(:handle_authentication_error, error)

        expect(controller).not_to have_received(:clear_authentication_cookies)
      end

      it 'redirects to identity service with the current URL as return_to' do
        controller.send(:handle_authentication_error, error)

        expect(controller).to have_received(:redirect_to)
          .with('https://auth.example.com/myott?return_to=%2Fsubscriptions%2Fmycommodities%3Fas_of%3D2025-06-20', allow_other_host: true)
      end
    end
  end

  describe '#clear_authentication_cookies' do
    let(:cookies_double) { instance_double(ActionDispatch::Cookies::CookieJar) }
    let(:identity_cookie_domain) { '.example.com' }

    before do
      allow(controller).to receive(:cookies).and_return(cookies_double)
      allow(TradeTariffFrontend).to receive(:identity_cookie_domain).and_return(identity_cookie_domain)
      allow(cookies_double).to receive(:delete)
    end

    it 'deletes the id_token cookie with correct domain' do
      controller.send(:clear_authentication_cookies)

      expect(cookies_double).to have_received(:delete)
        .with(:id_token, domain: identity_cookie_domain)
    end

    it 'deletes the refresh_token cookie with correct domain' do
      controller.send(:clear_authentication_cookies)

      expect(cookies_double).to have_received(:delete)
        .with(:refresh_token, domain: identity_cookie_domain)
    end
  end
end
