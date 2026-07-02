RSpec.describe FlagsmithClient do
  describe '.instance' do
    it 'raises if not configured' do
      original = described_class.instance
      described_class.instance = nil
      expect { described_class.instance }.to raise_error(RuntimeError, /not configured/)
    ensure
      described_class.instance = original
    end

    it 'returns the configured singleton' do
      expect(described_class.instance).to eq(TEST_FLAGSMITH_CLIENT)
    end
  end

  describe '.instance=' do
    it 'replaces the singleton' do
      replacement = instance_double(described_class)
      original = described_class.instance
      described_class.instance = replacement
      expect(described_class.instance).to equal(replacement)
    ensure
      described_class.instance = original
    end
  end

  describe '.configure' do
    it 'configures the singleton without an admin API key' do
      original = described_class.instance

      described_class.configure(
        environment_key: 'test-env-key',
        api_url: 'https://flags-edge.example.com/api/v1/',
      )

      expect(described_class.instance).to be_a(described_class)
    ensure
      described_class.instance = original
    end
  end

  describe '.new' do
    it 'configures the SDK with a short request timeout' do
      allow(Flagsmith::Client).to receive(:new).and_call_original

      described_class.new(
        environment_key: 'test-env-key',
        api_url: 'https://flags-edge.example.com/api/v1/',
      )

      expect(Flagsmith::Client).to have_received(:new).with(
        hash_including(request_timeout_seconds: 1),
      )
    end

    it 'configures the SDK with a quiet logger for request noise' do
      allow(Flagsmith::Client).to receive(:new).and_call_original

      described_class.new(
        environment_key: 'test-env-key',
        api_url: 'https://flags-edge.example.com/api/v1/',
      )

      expect(Flagsmith::Client).to have_received(:new).with(
        hash_including(logger: an_instance_of(described_class::SdkLogger)),
      )
    end
  end

  describe 'SDK logging' do
    subject(:logger) { described_class::SdkLogger.new(rails_logger) }

    let(:rails_logger) { instance_spy(ActiveSupport::Logger) }

    it 'suppresses debug request logs' do
      logger.debug('debug details')

      expect(rails_logger).not_to have_received(:debug)
    end

    it 'suppresses info request logs' do
      logger.info { 'request: POST https://flags-edge.example.com/api/v1/identities/' }

      expect(rails_logger).not_to have_received(:info)
    end

    it 'forwards warnings to the Rails logger' do
      logger.warn('Flagsmith warning')

      expect(rails_logger).to have_received(:warn).with('Flagsmith warning')
    end

    it 'forwards errors to the Rails logger' do
      logger.error { 'Flagsmith error' }

      expect(rails_logger).to have_received(:error).with('Flagsmith error')
    end
  end

  describe '#get_flags_for' do
    subject(:client) do
      described_class.new(
        environment_key: 'test-env-key',
        api_url: 'https://flagsmith.example.com/api/v1/',
      )
    end

    let(:identity) { Flagsmith::AnonymousIdentity.new('anon-123') }

    before do
      # The Flagsmith SDK POSTs to identities/ with a JSON body.
      # The identifier is the full prefixed string from AnonymousIdentity#identifier.
      stub_request(:post, 'https://flagsmith.example.com/api/v1/identities/')
        .with(
          headers: { 'X-Environment-Key' => 'test-env-key' },
          body: hash_including('identifier' => 'Anonymous:anon-123'),
        )
        .to_return(
          status: 200,
          body: {
            'flags' => [
              {
                'feature' => { 'name' => 'interactive_search', 'id' => 1 },
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
      expect(flags.is_feature_enabled('interactive_search')).to be true
    end

    it 'returns false for unknown flags' do
      flags = client.get_flags_for(identity)
      expect(flags.is_feature_enabled('unknown_flag')).to be false
    end
  end
end
