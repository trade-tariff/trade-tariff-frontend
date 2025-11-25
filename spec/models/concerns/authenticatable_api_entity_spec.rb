require 'spec_helper'

RSpec.describe AuthenticatableApiEntity do
  let(:test_class) do
    Class.new do
      include ApiEntity
      include AuthenticatableApiEntity

      attr_accessor :id, :name

      def self.name
        'TestEntity'
      end

      def self.singular_path
        '/test/:id'
      end
    end
  end

  before do
    stub_const('TestEntity', test_class)
  end

  describe '.headers' do
    let(:token) { 'test-auth-token' }

    it 'returns authorization headers with bearer token' do
      headers = test_class.headers(token)

      expect(headers).to eq({ authorization: "Bearer #{token}" })
    end

    context 'with nil token' do
      it 'returns headers with empty bearer' do
        headers = test_class.headers(nil)

        expect(headers).to eq({ authorization: 'Bearer ' })
      end
    end

    context 'with empty string token' do
      it 'returns headers with empty bearer' do
        headers = test_class.headers('')

        expect(headers).to eq({ authorization: 'Bearer ' })
      end
    end
  end

  describe '.find' do
    let(:token) { 'test-auth-token' }
    let(:entity_id) { '123' }
    let(:mock_api) { instance_spy(Faraday::Connection) }
    let(:mock_response) { instance_double(Faraday::Response, body: api_response) }
    let(:api_response) do
      {
        'data' => {
          'id' => entity_id,
          'type' => 'test_entity',
          'attributes' => { 'name' => 'Test Entity' },
        },
      }
    end

    before do
      allow(test_class).to receive_messages(
        api: mock_api,
        parse_jsonapi: api_response['data'],
      )
      allow(mock_api).to receive(:get).and_return(mock_response)
    end

    context 'with valid token' do
      it 'makes authenticated API call' do
        test_class.find(entity_id, token)

        expect(mock_api).to have_received(:get)
          .with('/test/123', {}, { authorization: "Bearer #{token}" })
      end

      it 'returns entity instance' do
        result = test_class.find(entity_id, token)

        expect(result).to be_a(test_class)
      end

      it 'passes options to API call' do
        options = { include: 'related_entity' }

        test_class.find(entity_id, token, options)

        expect(mock_api).to have_received(:get)
          .with('/test/123', options, { authorization: "Bearer #{token}" })
      end
    end

    context 'when development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      it 'makes API call even with nil token' do
        test_class.find(entity_id, nil)

        expect(mock_api).to have_received(:get)
          .with('/test/123', {}, { authorization: 'Bearer ' })
      end
    end

    context 'when non-development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
      end

      it 'returns nil with nil token' do
        result = test_class.find(entity_id, nil)

        expect(result).to be_nil
      end

      it 'does not make API call with nil token' do
        test_class.find(entity_id, nil)

        expect(mock_api).not_to have_received(:get)
      end
    end

    context 'when API returns unauthorized error' do
      before do
        allow(mock_api).to receive(:get)
          .and_raise(Faraday::UnauthorizedError.new('Unauthorized'))
      end

      it 'returns nil' do
        result = test_class.find(entity_id, token)

        expect(result).to be_nil
      end
    end

    context 'when API returns other errors' do
      before do
        allow(mock_api).to receive(:get)
          .and_raise(Faraday::ServerError.new('Server Error'))
      end

      it 'allows error to bubble up' do
        expect { test_class.find(entity_id, token) }
          .to raise_error(Faraday::ServerError)
      end
    end
  end

  describe '.all' do
    let(:token) { 'test-auth-token' }
    let(:mock_api) { instance_spy(Faraday::Connection) }
    let(:mock_response) { instance_double(Faraday::Response, body: api_response) }
    let(:api_response) do
      [
        { 'id' => '1', 'type' => 'test_entity', 'attributes' => { 'name' => 'Entity 1' } },
        { 'id' => '2', 'type' => 'test_entity', 'attributes' => { 'name' => 'Entity 2' } },
      ]
    end

    before do
      allow(test_class).to receive_messages(
        api: mock_api,
        parse_jsonapi: api_response,
      )
      allow(mock_api).to receive(:get).and_return(mock_response)
      allow(test_class).to receive(:collection_path).and_return('/test')
    end

    context 'with valid token' do
      it 'makes authenticated API call' do
        test_class.all(token)
        expect(mock_api).to have_received(:get)
          .with('/test', {}, { authorization: "Bearer #{token}" })
      end

      it 'returns array of entity instances' do
        result = test_class.all(token)
        expect(result.map(&:name)).to eq(['Entity 1', 'Entity 2'])
      end

      it 'passes options to API call' do
        options = { include: 'related_entity' }
        test_class.all(token, options)
        expect(mock_api).to have_received(:get)
          .with('/test', options, { authorization: "Bearer #{token}" })
      end
    end

    context 'when development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      it 'makes API call even with nil token' do
        test_class.all(nil)
        expect(mock_api).to have_received(:get)
          .with('/test', {}, { authorization: 'Bearer ' })
      end
    end

    context 'when non-development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
      end

      it 'returns empty array with nil token' do
        result = test_class.all(nil)
        expect(result).to eq([])
      end

      it 'does not make API call with nil token' do
        test_class.all(nil)
        expect(mock_api).not_to have_received(:get)
      end
    end

    context 'when API returns unauthorized error' do
      before do
        allow(mock_api).to receive(:get)
          .and_raise(Faraday::UnauthorizedError.new('Unauthorized'))
      end

      it 'returns empty array' do
        result = test_class.all(token)
        expect(result).to eq([])
      end
    end

    context 'when API returns other errors' do
      before do
        allow(mock_api).to receive(:get)
          .and_raise(Faraday::ServerError.new('Server Error'))
      end

      it 'allows error to bubble up' do
        expect { test_class.all(token) }
          .to raise_error(Faraday::ServerError)
      end
    end
  end

  describe 'concern behavior' do
    it 'includes UkOnlyApiEntity' do
      expect(test_class.included_modules).to include(UkOnlyApiEntity)
    end

    it 'adds class methods' do
      expect(test_class).to respond_to(:find, :headers)
    end
  end

  describe 'integration' do
    it 'is included in GroupedMeasureChange' do
      expect(TariffChanges::GroupedMeasureChange.included_modules)
        .to include(described_class)
    end
  end
end
