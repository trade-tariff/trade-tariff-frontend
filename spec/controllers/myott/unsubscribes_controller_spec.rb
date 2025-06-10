require 'spec_helper'

RSpec.describe Myott::UnsubscribesController, type: :controller do
  let(:subscription) { build(:subscription) }

  describe 'GET #show' do
    before do
      allow(controller).to receive(:current_subscription).and_return(subscription)
    end

    it 'renders the show template' do
      get :show, params: { id: subscription.uuid }
      expect(response).to render_template(:show)
    end
  end

  describe 'DELETE #destroy' do
    before do
      allow(controller).to receive(:current_subscription).and_return(subscription)
    end

    context 'when deletion is successful' do
      it 'redirects to the confirmation page' do
        allow(Subscription).to receive(:delete).with(subscription.uuid).and_return(true)
        delete :destroy, params: { id: subscription.uuid }
        expect(response).to redirect_to(confirmation_myott_unsubscribes_path)
      end
    end

    context 'when deletion fails' do
      it 'sets the flash error message' do
        allow(Subscription).to receive(:delete).with(subscription.uuid).and_return(false)
        delete :destroy, params: { id: subscription.uuid }
        expect(flash[:error]).to eq('There was an error unsubscribing you. Please try again.')
      end

      it 'renders the show template' do
        allow(Subscription).to receive(:delete).with(subscription.uuid).and_return(false)
        delete :destroy, params: { id: subscription.uuid }
        expect(response).to render_template(:show)
      end
    end

    describe 'GET #confirmation' do
      before do
        cookies[:id_token] = 'test_uuid'
      end

      it 'deletes the subscription_uuid cookie' do
        get :confirmation
        expect(cookies[:id_token]).to be_nil
      end

      it 'assigns the correct header' do
        get :confirmation
        expect(assigns(:header)).to eq('You have unsubscribed')
      end

      it 'assigns the correct message' do
        get :confirmation
        expect(assigns(:message)).to eq('You will no longer receive any Stop Press emails from the UK Trade Tariff Service.')
      end
    end
  end

  describe 'before_action :authenticate' do
    context 'when current_subscription is nil' do
      before do
        allow(controller).to receive(:current_subscription).and_return(nil)
      end

      it 'redirects to myott_start_path' do
        get :show, params: { id: 1 }
        expect(response).to redirect_to(myott_start_path)
      end
    end
  end
end
