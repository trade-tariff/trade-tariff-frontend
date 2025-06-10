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
end
