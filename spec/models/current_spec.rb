RSpec.describe Current do
  it 'can store and retrieve a flagsmith identity' do
    identity = Flagsmith::UserIdentity.new('neil@example.com')
    Current.flagsmith_identity = identity
    expect(Current.flagsmith_identity).to eq(identity)
  end

  it 'can store and retrieve memoised flags' do
    flags = double(:flags)
    Current.flagsmith_flags = flags
    expect(Current.flagsmith_flags).to eq(flags)
  end

  it 'resets between examples' do
    expect(Current.flagsmith_identity).to be_nil
    expect(Current.flagsmith_flags).to be_nil
  end
end
