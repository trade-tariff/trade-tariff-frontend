RSpec.describe Flagsmith::AnonymousIdentity do
  subject(:identity) { described_class.new('abc-123') }

  it 'exposes the identifier string' do
    expect(identity.identifier).to eq('Anonymous:abc-123')
  end
end
