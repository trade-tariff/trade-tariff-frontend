RSpec.describe Flipper::AnonymousActor do
  describe '#flipper_id' do
    it 'returns a namespaced anonymous identifier' do
      expect(described_class.new('abc-uuid').flipper_id).to eq('Anonymous:abc-uuid')
    end
  end
end
