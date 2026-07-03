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
    subject(:client) do
      described_class.new(
        api_url: 'https://flagsmith.example.com',
        api_token: 'test-token',
      )
    end

    before do
      stub_request(:post, 'https://flagsmith.example.com/api/v1/traits/')
        .with(
          headers: { 'Authorization' => 'Api-Key test-token' },
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

    it 'POSTs the trait to the management API' do
      client.set_trait('Anonymous:abc123', 'interactive_search', true)

      expect(WebMock).to have_requested(:post, 'https://flagsmith.example.com/api/v1/traits/')
        .with(body: hash_including(trait_key: 'interactive_search', trait_value: true))
    end
  end
end
