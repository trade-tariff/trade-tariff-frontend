RSpec.describe Flagsmith::UserIdentity do
  subject(:identity) { described_class.new('neil@example.com') }

  it 'exposes the identifier string' do
    expect(identity.identifier).to eq('User:neil@example.com')
  end
end
