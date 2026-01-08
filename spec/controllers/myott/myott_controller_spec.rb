RSpec.describe Myott::MyottController, type: :controller do
  include MyottAuthenticationHelpers

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
end
