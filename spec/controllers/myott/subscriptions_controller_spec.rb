require 'spec_helper'

RSpec.describe Myott::SubscriptionsController, type: :controller do
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
        allow(controller).to receive(:current_user).and_return(user)
        get :invalid
      end

      it { is_expected.to redirect_to myott_path }
    end

    context 'when a user does not exist' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :invalid
      end

      it { is_expected.not_to redirect_to myott_path }
    end
  end

  describe 'GET #index' do
    context 'when current_user is not valid' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        get :index
      end

      it { is_expected.to redirect_to 'http://localhost:3005/myott' }
    end

    context 'when current_user is valid' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
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
        let(:stop_press_subscription) { build(:subscription, subscription_type: 'stop_press') }
        let(:my_commodities_subscription) { build(:subscription, subscription_type: 'my_commodities') }

        before do
          allow(TradeTariffFrontend).to receive(:my_commodities?).and_return(true)
          allow(controller).to receive(:current_subscription).with('stop_press').and_return(stop_press_subscription)
          allow(controller).to receive(:current_subscription).with('my_commodities').and_return(my_commodities_subscription)
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
