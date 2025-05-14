require 'spec_helper'

RSpec.describe Myott::MyottController, type: :controller do
  describe '#current_user' do
    let(:id_token) { 'encrypted+token' }
    let(:decrypted_token) { 'decrypted_token' }

    before do
      allow(controller).to receive(:cookies).and_return(id_token: id_token)
      allow(EncryptionService).to receive(:decrypt_string).with(CGI.unescape(id_token)).and_return(decrypted_token)
      allow(JWT).to receive(:decode).with(decrypted_token, nil, false).and_return('user_data')
    end

    it 'decodes the ID token and returns the current user' do
      result = controller.send(:current_user)
      expect(result).to eq('user_data')
    end
  end
end
