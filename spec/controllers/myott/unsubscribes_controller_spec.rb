RSpec.describe Myott::UnsubscribesController, type: :controller do
  include MyottAuthenticationHelpers

  let(:subscription) { build(:subscription, subscription_type: 'stop_press') }

  describe 'GET #show' do
    before do
      allow(controller).to receive_messages(current_subscription: subscription, subscription_type: subscription['subscription_type'])
      get :show, params: { id: subscription.uuid, subscription_type: subscription['subscription_type'] }
    end

    it 'renders the subscription-specific template' do
      expect(response).to render_template("myott/unsubscribes/#{subscription['subscription_type']}")
    end
  end

  describe 'DELETE #destroy' do
    before do
      allow(controller).to receive_messages(current_subscription: subscription, subscription_type: subscription['subscription_type'])
    end

    context 'when subscription_type is stop_press' do
      context 'when deletion is successful' do
        it 'redirects to the confirmation page' do
          allow(Subscription).to receive(:delete).with(subscription.uuid).and_return(true)
          delete :destroy, params: { id: subscription.uuid }
          expect(response).to redirect_to(confirmation_myott_unsubscribes_path(subscription_type: subscription['subscription_type']))
        end
      end
    end

    context 'when subscription_type is my_commodities' do
      let(:subscription) { build(:subscription, subscription_type: 'my_commodities') }

      context 'when user confirms' do
        it 'redirects to the confirmation page' do
          allow(Subscription).to receive(:delete).with(subscription.uuid).and_return(true)
          allow(controller).to receive_messages(user_declined?: false, user_confirmed?: true)
          delete :destroy, params: { id: subscription.uuid }
          expect(response).to redirect_to(confirmation_myott_unsubscribes_path(subscription_type: subscription['subscription_type']))
        end
      end

      context 'when user declines' do
        it 'redirects to myott_path' do
          allow(controller).to receive_messages(user_declined?: true)
          delete :destroy, params: { id: subscription.uuid }
          expect(response).to redirect_to(myott_path)
        end
      end

      context 'when user neither confirms nor declines' do
        before do
          allow(controller).to receive_messages(user_declined?: false, user_confirmed?: false)
          delete :destroy, params: { id: subscription.uuid }
        end

        let(:error_message) { 'Select yes if you want to unsubscribe from your commodity watch list' }

        it 'assigns the alert message' do
          expect(assigns(:alert)).to eq(error_message)
        end

        it 'sets the flash error message' do
          expect(flash.now[:select_error]).to eq(error_message)
        end

        it 'renders the show template with an error' do
          expect(response).to render_template(:my_commodities)
        end
      end
    end

    context 'when deletion fails' do
      it 'sets the flash error message' do
        allow(Subscription).to receive(:delete).with(subscription.uuid).and_return(false)
        delete :destroy, params: { id: subscription.uuid }
        expect(assigns(:alert)).to eq('There was an error unsubscribing you. Please try again.')
      end

      it 'renders the show template' do
        allow(Subscription).to receive(:delete).with(subscription.uuid).and_return(false)
        delete :destroy, params: { id: subscription.uuid }
        expect(response).to render_template(:stop_press)
      end
    end
  end

  describe 'GET #confirmation' do
    before do
      cookies[:id_token] = 'test_uuid'
      get :confirmation, params: { subscription_type: subscription['subscription_type'] }
    end

    it 'assigns the subscription_type' do
      expect(assigns(:subscription_type)).to eq(subscription['subscription_type'])
    end

    it 'deletes the subscription_uuid cookie' do
      expect(cookies[:id_token]).to be_nil
    end

    it 'assigns the correct header' do
      expect(assigns(:header)).to eq('You have unsubscribed')
    end

    it 'assigns the correct message' do
      expect(assigns(:message)).to eq('You will no longer receive any Stop Press emails from the UK Trade Tariff Service.')
    end

    context 'when request host contains www' do
      before do
        request.host = 'www.example.com'
        allow(cookies).to receive(:delete).and_call_original
      end

      it 'deletes the id_token cookie with the correct domain' do
        expect_any_instance_of(ActionDispatch::Cookies::CookieJar).to receive(:delete).with(:id_token, hash_including(domain: '.example.com')) # rubocop:disable RSpec/AnyInstance
        get :confirmation, params: { subscription_type: subscription['subscription_type'] }
      end
    end
  end

  describe 'before_action :authenticate' do
    context 'when current_subscription is nil' do
      before do
        allow(controller).to receive_messages(current_subscription: nil, subscription_type: nil)
      end

      it 'redirects to myott_start_path' do
        get :show, params: { id: 1 }
        expect(response).to redirect_to(myott_start_path)
      end
    end
  end
end
