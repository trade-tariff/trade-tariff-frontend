require 'spec_helper'

RSpec.describe Myott::MyottController, type: :controller do
  describe '#current_user' do
    let(:id_token) { 'encrypted_token' }
    let(:decrypted_token) { 'decrypted_token' }

    before do
      allow(controller).to receive(:cookies).and_return(id_token: id_token)
      allow(EncryptionService).to receive(:decrypt_string).with(id_token).and_return(decrypted_token)
    end

    it 'decodes the ID token and returns the current user' do
      allow(JWT).to receive(:decode).with(decrypted_token, nil, false).and_return('user_data')

      result = controller.send(:current_user)

      expect(result).to eq('user_data')
    end
  end
end

