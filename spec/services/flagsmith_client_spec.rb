RSpec.describe FlagsmithClient do
  describe '.instance' do
    # Reset before each example so we test the real lazy-init, not the
    # TEST_FLAGSMITH_CLIENT double that before(:suite) installs.
    before { described_class.instance = nil }

    after { described_class.instance = TEST_FLAGSMITH_CLIENT }

    it 'returns the singleton' do
      expect(described_class.instance).to be_a(described_class)
    end

    it 'returns the same object on repeated calls' do
      expect(described_class.instance).to equal(described_class.instance)
    end
  end

  describe '.instance=' do
    it 'replaces the singleton' do
      replacement = double(:client)
      original = described_class.instance
      described_class.instance = replacement
      expect(described_class.instance).to equal(replacement)
    ensure
      described_class.instance = original
    end
  end

  describe '#get_flags_for' do
    subject(:client) do
      described_class.new(
        environment_key: 'test-env-key',
        api_url: 'https://flagsmith.example.com/api/v1/',
        admin_api_key: 'test-admin-key',
      )
    end

    let(:identity) { Flagsmith::UserIdentity.new('neil@example.com') }

    before do
      # The Flagsmith SDK POSTs to identities/ with a JSON body.
      # The identifier is the full prefixed string from UserIdentity#identifier.
      stub_request(:post, 'https://flagsmith.example.com/api/v1/identities/')
        .with(
          headers: { 'X-Environment-Key' => 'test-env-key' },
          body: hash_including('identifier' => 'User:neil@example.com'),
        )
        .to_return(
          status: 200,
          body: {
            'flags' => [
              {
                'feature' => { 'name' => 'green_lanes', 'id' => 1 },
                'enabled' => true,
                'feature_state_value' => nil,
              },
            ],
            'traits' => [],
          }.to_json,
          headers: { 'Content-Type' => 'application/json' },
        )
    end

    it 'returns a flags collection with the enabled flag' do
      flags = client.get_flags_for(identity)
      expect(flags.is_feature_enabled('green_lanes')).to be true
    end

    it 'returns false for unknown flags' do
      flags = client.get_flags_for(identity)
      expect(flags.is_feature_enabled('unknown_flag')).to be false
    end
  end
end
