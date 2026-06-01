RSpec.describe Current do
  it 'can store and retrieve a flagsmith identity' do
    identity = Flagsmith::UserIdentity.new('neil@example.com')
    described_class.flagsmith_identity = identity
    expect(described_class.flagsmith_identity).to eq(identity)
  end

  it 'can store and retrieve memoised flags' do
    flags = Object.new
    described_class.flagsmith_flags = flags
    expect(described_class.flagsmith_flags).to eq(flags)
  end

  it 'resets flagsmith_identity between examples' do
    expect(described_class.flagsmith_identity).to be_nil
  end

  it 'resets flagsmith_flags between examples' do
    expect(described_class.flagsmith_flags).to be_nil
  end
end
