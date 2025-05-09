require 'spec_helper'

RSpec.describe Myott::SubscriptionsController, type: :controller do
  describe 'GET dashboard' do
    before do
      get :dashboard
    end

    it { is_expected.to respond_with(:success) }
    it { expect(assigns(:email)).to be_present }

    context 'when current_user exists' do
      before do
        allow(controller).to receive(:current_user).and_return({ 'email' => 'test@example.com' })
      end

      it 'assigns @email with current_user email' do
        get :dashboard
        expect(assigns(:email)).to eq('test@example.com')
      end
    end
  end
end
