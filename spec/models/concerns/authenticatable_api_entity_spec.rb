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
      context 'with error reason in response' do
        let(:error_response) do
          {
            body: '{"errors":[{"code":"invalid_token","detail":"Token is invalid"}]}',
            status: 401,
          }
        end

        before do
          error = Faraday::UnauthorizedError.new('Unauthorized')
          allow(error).to receive(:response).and_return(error_response)
          allow(mock_api).to receive(:get).and_raise(error)
        end

        it 'raises AuthenticationError with reason', :aggregate_failures do
          expect { test_class.find(entity_id, token) }
            .to raise_error(AuthenticationError) do |error|
              expect(error.reason).to eq('invalid_token')
              expect(error.message).to eq('Unauthorized')
            end
        end
      end

      context 'without error reason in response' do
        before do
          allow(mock_api).to receive(:get)
            .and_raise(Faraday::UnauthorizedError.new('Unauthorized'))
        end

        it 'returns nil' do
          result = test_class.find(entity_id, token)

          expect(result).to be_nil
        end
      end

      context 'with malformed JSON in response' do
        let(:error_response) do
          {
            body: 'not valid json',
            status: 401,
          }
        end

        before do
          error = Faraday::UnauthorizedError.new('Unauthorized')
          allow(error).to receive(:response).and_return(error_response)
          allow(mock_api).to receive(:get).and_raise(error)
        end

        it 'returns nil' do
          result = test_class.find(entity_id, token)

          expect(result).to be_nil
        end
      end
    end

    context 'when API returns other errors' do
      before do
        allow(mock_api).to receive(:get)
          .and_raise(Faraday::ServerError.new('Server Error'))
      end

      it 'raises invalid token error', :aggregate_failures do
        expect { test_class.find(entity_id, token) }
          .to raise_error(AuthenticationError) do |error|
            expect(error.reason).to eq('invalid_token')
            expect(error.message).to eq('Server Error')
          end
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
      context 'with error reason in response' do
        let(:error_response) do
          {
            body: '{"errors":[{"code":"not_in_group","detail":"User not in required group"}]}',
            status: 401,
          }
        end

        before do
          error = Faraday::UnauthorizedError.new('Unauthorized')
          allow(error).to receive(:response).and_return(error_response)
          allow(mock_api).to receive(:get).and_raise(error)
        end

        it 'raises AuthenticationError with reason', :aggregate_failures do
          expect { test_class.all(token) }
            .to raise_error(AuthenticationError) do |error|
              expect(error.reason).to eq('not_in_group')
              expect(error.message).to eq('Unauthorized')
            end
        end
      end

      context 'without error reason in response' do
        before do
          allow(mock_api).to receive(:get)
            .and_raise(Faraday::UnauthorizedError.new('Unauthorized'))
        end

        it 'returns empty array' do
          result = test_class.all(token)
          expect(result).to eq([])
        end
      end

      context 'with malformed JSON in response' do
        let(:error_response) do
          {
            body: 'not valid json',
            status: 401,
          }
        end

        before do
          error = Faraday::UnauthorizedError.new('Unauthorized')
          allow(error).to receive(:response).and_return(error_response)
          allow(mock_api).to receive(:get).and_raise(error)
        end

        it 'returns empty array' do
          result = test_class.all(token)
          expect(result).to eq([])
        end
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

  describe '.handle_unauthorized_error' do
    let(:default_return_value) { 'default_value' }

    context 'when error has extractable reason' do
      let(:error_response) do
        {
          body: '{"errors":[{"code":"expired","detail":"Token has expired"}]}',
          status: 401,
        }
      end
      let(:error) do
        error = Faraday::UnauthorizedError.new('Token expired')
        allow(error).to receive(:response).and_return(error_response)
        error
      end

      it 'raises AuthenticationError with extracted reason', :aggregate_failures do
        expect { test_class.send(:handle_unauthorized_error, error) }
          .to raise_error(AuthenticationError) do |raised_error|
            expect(raised_error.reason).to eq('expired')
            expect(raised_error.message).to eq('Token expired')
          end
      end

      it 'raises AuthenticationError regardless of default_return value' do
        expect { test_class.send(:handle_unauthorized_error, error, default_return: default_return_value) }
          .to raise_error(AuthenticationError)
      end
    end

    context 'when error has no extractable reason' do
      let(:error) { Faraday::UnauthorizedError.new('Generic error') }

      it 'returns nil when no default_return specified' do
        result = test_class.send(:handle_unauthorized_error, error)

        expect(result).to be_nil
      end

      it 'returns default_return value when specified' do
        result = test_class.send(:handle_unauthorized_error, error, default_return: default_return_value)

        expect(result).to eq(default_return_value)
      end
    end
  end

  describe '.extract_error_reason' do
    context 'with valid error response containing code' do
      let(:error_response) do
        {
          body: '{"errors":[{"code":"missing_jwks_keys","detail":"JWKS keys are missing"}]}',
          status: 401,
        }
      end
      let(:error) do
        error = Faraday::UnauthorizedError.new('Error')
        allow(error).to receive(:response).and_return(error_response)
        error
      end

      it 'extracts the error code' do
        reason = test_class.send(:extract_error_reason, error)

        expect(reason).to eq('missing_jwks_keys')
      end
    end

    context 'with response containing multiple errors' do
      let(:error_response) do
        {
          body: '{"errors":[{"code":"first_error","detail":"First"},{"code":"second_error","detail":"Second"}]}',
          status: 401,
        }
      end
      let(:error) do
        error = Faraday::UnauthorizedError.new('Error')
        allow(error).to receive(:response).and_return(error_response)
        error
      end

      it 'extracts the first error code' do
        reason = test_class.send(:extract_error_reason, error)

        expect(reason).to eq('first_error')
      end
    end

    context 'with response containing no code field' do
      let(:error_response) do
        {
          body: '{"errors":[{"detail":"No code field"}]}',
          status: 401,
        }
      end
      let(:error) do
        error = Faraday::UnauthorizedError.new('Error')
        allow(error).to receive(:response).and_return(error_response)
        error
      end

      it 'returns nil' do
        reason = test_class.send(:extract_error_reason, error)

        expect(reason).to be_nil
      end
    end

    context 'with malformed JSON response' do
      let(:error_response) do
        {
          body: 'not valid json',
          status: 401,
        }
      end
      let(:error) do
        error = Faraday::UnauthorizedError.new('Error')
        allow(error).to receive(:response).and_return(error_response)
        error
      end

      it 'returns nil' do
        reason = test_class.send(:extract_error_reason, error)

        expect(reason).to be_nil
      end
    end

    context 'with nil response' do
      let(:error) do
        error = Faraday::UnauthorizedError.new('Error')
        allow(error).to receive(:response).and_return(nil)
        error
      end

      it 'returns nil' do
        reason = test_class.send(:extract_error_reason, error)

        expect(reason).to be_nil
      end
    end

    context 'with response missing body' do
      let(:error_response) { { status: 401 } }
      let(:error) do
        error = Faraday::UnauthorizedError.new('Error')
        allow(error).to receive(:response).and_return(error_response)
        error
      end

      it 'returns nil' do
        reason = test_class.send(:extract_error_reason, error)

        expect(reason).to be_nil
      end
    end
  end
end
