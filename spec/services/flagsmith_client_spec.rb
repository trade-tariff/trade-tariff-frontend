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
      replacement = instance_double(described_class)
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

  describe 'Admin API mutations' do
    subject(:client) do
      described_class.new(
        environment_key: 'test-env-key',
        api_url: 'https://flagsmith.example.com/api/v1/',
        admin_api_key: 'test-admin-key',
      )
    end

    let(:identity) { Flagsmith::UserIdentity.new('neil@example.com') }
    let(:identity_pk) { 42 }
    let(:admin_headers) { { 'Authorization' => 'Token test-admin-key' } }
    let(:base_url) { 'https://flagsmith.example.com/api/v1/environments/test-env-key/identities' }

    before do
      # Stub identity lookup (used by enable/disable/get_overrides/delete)
      stub_request(:get, "#{base_url}/")
        .with(query: { q: 'User:neil@example.com' }, headers: admin_headers)
        .to_return(
          status: 200,
          body: { 'results' => [{ 'id' => identity_pk, 'identifier' => 'User:neil@example.com' }] }.to_json,
          headers: { 'Content-Type' => 'application/json' },
        )
    end

    describe '#enable_for_identity' do
      before do
        # No existing feature state for this identity
        stub_request(:get, "#{base_url}/#{identity_pk}/featurestates/")
          .with(headers: admin_headers)
          .to_return(
            status: 200,
            body: { 'results' => [] }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )

        # Look up feature id by name
        stub_request(:get, 'https://flagsmith.example.com/api/v1/features/featurestates/')
          .with(
            query: { environment: 'test-env-key', feature__name: 'green_lanes' },
            headers: admin_headers,
          )
          .to_return(
            status: 200,
            body: { 'results' => [{ 'feature' => 7 }] }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )

        stub_request(:post, "#{base_url}/#{identity_pk}/featurestates/")
          .with(
            body: { 'feature' => 7, 'enabled' => true }.to_json,
            headers: admin_headers,
          )
          .to_return(status: 201, body: '{}', headers: { 'Content-Type' => 'application/json' })
      end

      it 'POSTs a new enabled feature state for the identity' do
        client.enable_for_identity(:green_lanes, identity)
        expect(WebMock).to have_requested(:post, "#{base_url}/#{identity_pk}/featurestates/")
          .with(body: { 'feature' => 7, 'enabled' => true }.to_json)
      end
    end

    describe '#disable_for_identity' do
      before do
        # Existing feature state to patch
        stub_request(:get, "#{base_url}/#{identity_pk}/featurestates/")
          .with(headers: admin_headers)
          .to_return(
            status: 200,
            body: {
              'results' => [
                { 'id' => 99, 'feature' => { 'name' => 'green_lanes' }, 'enabled' => true },
              ],
            }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )

        stub_request(:patch, "#{base_url}/#{identity_pk}/featurestates/99/")
          .with(
            body: { 'enabled' => false }.to_json,
            headers: admin_headers,
          )
          .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
      end

      it 'PATCHes the existing feature state to disabled' do
        client.disable_for_identity(:green_lanes, identity)
        expect(WebMock).to have_requested(:patch, "#{base_url}/#{identity_pk}/featurestates/99/")
          .with(body: { 'enabled' => false }.to_json)
      end
    end

    describe '#get_identity_overrides' do
      before do
        stub_request(:get, "#{base_url}/#{identity_pk}/featurestates/")
          .with(headers: admin_headers)
          .to_return(
            status: 200,
            body: {
              'results' => [
                { 'feature' => { 'name' => 'green_lanes' }, 'enabled' => true },
                { 'feature' => { 'name' => 'roo_wizard' }, 'enabled' => false },
              ],
            }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )
      end

      it 'returns only the names of enabled overrides' do
        expect(client.get_identity_overrides('User:neil@example.com')).to eq(%w[green_lanes])
      end
    end

    describe '#delete_identity' do
      before do
        stub_request(:delete, "#{base_url}/#{identity_pk}/")
          .with(headers: admin_headers)
          .to_return(status: 204, body: '')
      end

      it 'DELETEs the identity by its pk' do
        client.delete_identity('User:neil@example.com')
        expect(WebMock).to have_requested(:delete, "#{base_url}/#{identity_pk}/")
      end
    end
  end
end
