require 'spec_helper'

RSpec.describe Myott::MyottController, type: :controller do
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

    before do
      allow(Subscription).to receive(:find).and_return(subscription)
      allow(controller).to receive(:params).and_return(id: subscription.uuid)
    end

    it 'returns the current subscription' do
      result = controller.send(:current_subscription)
      expect(result).to eq(subscription)
    end
  end

  describe '#get_subscription' do
    let(:subscription) { build(:subscription) }
    let(:subscription_type) { 'my_commodities' }
    let(:user_subscription_hash) do
      [{
        'subscription_type' => subscription_type,
        'id' => subscription.uuid,
      }]
    end

    before do
      allow(controller).to receive(:cookies).and_return(id_token: 'token123')
      allow(User).to receive(:find).and_return({ subscriptions: user_subscription_hash })
      allow(Subscription).to receive(:find).with(subscription.uuid, 'token123')
                                          .and_return(subscription)
    end

    it 'returns the subscription for the matching subscription_type' do
      result = controller.send(:get_subscription, subscription_type)
      expect(result).to eq(subscription)
    end
  end
end
