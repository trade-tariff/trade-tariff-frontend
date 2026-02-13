RSpec.describe Myott::UnsubscribesController, type: :controller do
  include MyottAuthenticationHelpers

  let(:subscription) { build(:subscription, :stop_press) }

  describe 'GET #show' do
    before do
      allow(controller).to receive_messages(current_subscription: subscription, subscription_type: subscription.subscription_type_name)
      get :show, params: { id: subscription.uuid, subscription_type: subscription.subscription_type_name }
    end

    it 'renders the subscription-specific template' do
      expect(response).to render_template("myott/unsubscribes/#{subscription.subscription_type_name}")
    end
  end

  describe 'DELETE #destroy' do
    before do
      allow(controller).to receive_messages(current_subscription: subscription, subscription_type: subscription.subscription_type_name)
    end

    context 'when subscription_type is stop_press' do
      context 'when deletion is successful' do
        it 'redirects to the confirmation page' do
          allow(Subscription).to receive(:delete).with(subscription.uuid).and_return(true)
          delete :destroy, params: { id: subscription.uuid }
          expect(response).to redirect_to(confirmation_myott_unsubscribes_path(subscription_type: subscription.subscription_type_name))
        end
      end
    end

    context 'when subscription_type is my_commodities' do
      let(:subscription) { build(:subscription, :my_commodities) }

      context 'when user confirms' do
        it 'redirects to the confirmation page' do
          allow(Subscription).to receive(:delete).with(subscription.uuid).and_return(true)
          delete :destroy, params: {
            id: subscription.uuid,
            myott_unsubscribe_my_commodities_form: { decision: 'true' },
          }
          expect(response).to redirect_to(confirmation_myott_unsubscribes_path(subscription_type: subscription.subscription_type_name))
        end
      end

      context 'when user declines' do
        it 'redirects to myott_path' do
          delete :destroy, params: {
            id: subscription.uuid,
            myott_unsubscribe_my_commodities_form: { decision: 'false' },
          }
          expect(response).to redirect_to(myott_mycommodities_path)
        end
      end

      context 'when user neither confirms nor declines' do
        before do
          delete :destroy, params: {
            id: subscription.uuid,
            myott_unsubscribe_my_commodities_form: { decision: nil },
          }
        end

        it 'displays validation errors' do
          expect(assigns(:form).errors[:decision]).to be_present
        end

        it 'renders the my_commodities template again' do
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
      get :confirmation, params: { subscription_type: subscription.subscription_type_name }
    end

    it 'assigns the subscription_type' do
      expect(assigns(:subscription_type)).to eq(subscription.subscription_type_name)
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

    it 'deletes the id_token and refresh_token cookie', :aggregate_failures do
      cookies_spy = instance_spy(ActionDispatch::Cookies::CookieJar)
      allow(controller).to receive(:cookies).and_return(cookies_spy)

      get :confirmation, params: { subscription_type: subscription.subscription_type_name }

      expect(cookies_spy).to have_received(:delete).with(:id_token, hash_including(domain: :all))
      expect(cookies_spy).to have_received(:delete).with(:refresh_token, hash_including(domain: :all))
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
