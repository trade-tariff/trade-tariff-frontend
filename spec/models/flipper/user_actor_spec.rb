RSpec.describe Flipper::UserActor do
  describe '#flipper_id' do
    it 'returns a namespaced user identifier' do
      expect(described_class.new('user-123').flipper_id).to eq('User:user-123')
    end
  end
end
