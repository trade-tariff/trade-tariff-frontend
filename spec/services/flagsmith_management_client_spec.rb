RSpec.describe FlagsmithManagementClient do
  describe '.instance' do
    it 'raises if not configured' do
      original = described_class.instance
      described_class.instance = nil
      expect { described_class.instance }.to raise_error(RuntimeError, /not configured/)
    ensure
      described_class.instance = original
    end
  end

  describe '.configured?' do
    it 'returns false when instance is nil' do
      original = described_class.instance
      described_class.instance = nil
      expect(described_class.configured?).to be false
    ensure
      described_class.instance = original
    end

    it 'returns true when instance is set' do
      expect(described_class.configured?).to be true
    end
  end

  describe '#set_trait' do
    subject(:client) { described_class.new(environment_key: 'test-env-key') }

    before do
      stub_request(:post, "#{described_class::CORE_API_URL}/api/v1/traits/")
        .with(
          headers: { 'X-Environment-Key' => 'test-env-key' },
          body: {
            identity: { identifier: 'Anonymous:abc123' },
            trait_key: 'interactive_search',
            trait_value: true,
          },
        )
        .to_return(
          status: 200,
          body: { trait_key: 'interactive_search', trait_value: true }.to_json,
          headers: { 'Content-Type' => 'application/json' },
        )
    end

    it 'POSTs the trait to the core API using the SDK trait endpoint' do
      client.set_trait('Anonymous:abc123', 'interactive_search', true)

      expect(WebMock).to have_requested(:post, "#{described_class::CORE_API_URL}/api/v1/traits/")
        .with(body: hash_including(trait_key: 'interactive_search', trait_value: true))
    end
  end
end
