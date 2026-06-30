RSpec.describe Current do
  it 'can store and retrieve a flagsmith identity' do
    identity = Flagsmith::AnonymousIdentity.new('anon-123')
    described_class.flagsmith_identity = identity
    expect(described_class.flagsmith_identity).to eq(identity)
  end

  it 'can store and retrieve memoised flags' do
    flags = Object.new
    described_class.flagsmith_flags = flags
    expect(described_class.flagsmith_flags).to eq(flags)
  end

  it 'can store and retrieve flagsmith unavailability state' do
    described_class.flagsmith_unavailable = true
    expect(described_class.flagsmith_unavailable).to be true
  end

  it 'resets flagsmith_identity between examples' do
    expect(described_class.flagsmith_identity).to be_nil
  end

  it 'resets flagsmith_flags between examples' do
    expect(described_class.flagsmith_flags).to be_nil
  end

  it 'resets flagsmith_unavailable between examples' do
    expect(described_class.flagsmith_unavailable).to be_nil
  end
end
