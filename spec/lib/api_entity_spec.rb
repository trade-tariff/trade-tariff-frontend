require 'spec_helper'

RSpec.describe ApiEntity do
  let :mock_entity do
    Class.new do
      include ApiEntity

      collection_path '/mock_entities'

      attr_accessor :name, :age

      has_many :parts, class_name: 'Part'
      has_one :part, class_name: 'Part'

      def self.name
        'MockEntity'
      end
    end
  end

  describe '#inspect' do
    context 'when initialized with attributes' do
      subject(:api_entity) { mock_entity.new(name: 'Bilbo Baggins', age: 111) }

      it { expect(api_entity.inspect).to eq('name' => 'Bilbo Baggins', 'age' => 111) }
    end

    context 'when initialized without attributes and having them assigned separately' do
      subject(:api_entity) { mock_entity.new }

      before do
        api_entity.name = 'Hari Seldon'
        api_entity.age = 79
      end

      it { expect(api_entity.inspect).to eq('name' => 'Hari Seldon', 'age' => 79) }
    end
  end

  describe '#resource_type' do
    subject(:resource_type) { mock_entity.new(attributes).resource_type }

    context 'when initialized with the resource type' do
      let(:attributes) { { resource_type: 'foo' } }

      it { is_expected.to eq('foo') }
    end

    context 'when initialized without the resource type' do
      let(:attributes) { {} }

      it { is_expected.to eq('mock_entity') }
    end
  end

  describe '#resource_id' do
    subject(:resource_id) { instance.resource_id }

    let(:instance) { mock_entity.new(resource_id: '123') }

    it { is_expected.to eq '123' }

    context 'when reassigning id' do
      let(:instance) do
        mock_entity.new(resource_id: '123').tap do |instance|
          instance.resource_id = '456'
        end
      end

      it { is_expected.to eq '123' }
    end
  end

  describe '#find' do
    subject(:request) { mock_entity.find(123) }

    before do
      stub_request(:get, "#{api_endpoint}/mock_entities/123").and_return \
        status: status,
        headers: headers,
        body: body
    end

    let(:api_endpoint) { TradeTariffFrontend::ServiceChooser.uk_host }
    let(:status) { 200 }
    let(:headers) { { 'content-type' => 'application/json; charset=utf-8' } }

    context 'with valid response' do
      let(:body) { file_fixture('jsonapi/singular_no_relationship.json').read }

      it { is_expected.to have_attributes resource_id: '123', name: 'Joe', age: 21 }
    end

    context 'with valid response and nil relationship' do
      let(:body) { file_fixture('jsonapi/singular_valid_null_singular_relationship.json').read }

      it { is_expected.to have_attributes resource_id: '123', name: 'Joe', age: 21, part: nil }
    end

    context 'with 400 response' do
      let(:status) { 400 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::BadRequestError }
    end

    context 'with 404 response' do
      let(:status) { 404 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::ResourceNotFound }
    end

    context 'with error response' do
      let(:status) { 500 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::ServerError }
    end

    context 'with 502 response' do
      let(:status) { 502 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::ServerError }
    end

    context 'with unparseable response' do
      let :body do
        file_fixture('jsonapi/singular_invalid_relationship.json').read
      end

      it 'raises descriptive exception' do
        expect { request }.to raise_exception \
          described_class::UnparseableResponseError,
          %r{Error parsing #{api_endpoint}/mock_entities/123 with headers:}
      end
    end
  end

  describe '#all' do
    subject(:request) { mock_entity.all }

    before do
      stub_request(:get, "#{api_endpoint}/mock_entities").and_return \
        status: status,
        headers: headers,
        body: body
    end

    let(:api_endpoint) { TradeTariffFrontend::ServiceChooser.uk_host }
    let(:status) { 200 }
    let(:headers) { { 'content-type' => 'application/json; charset=utf-8' } }

    context 'with valid response' do
      let(:body) { file_fixture('jsonapi/multiple_no_relationship.json').read }

      it { is_expected.to have_attributes length: 1 }
      it { expect(request.first).to have_attributes resource_id: '123', name: 'Joe', age: 21 }
    end

    context 'with 400 response' do
      let(:status) { 400 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::BadRequestError }
    end

    context 'with 404 response' do
      let(:status) { 404 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::ResourceNotFound }
    end

    context 'with error response' do
      let(:status) { 500 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::ServerError }
    end

    context 'with 502 response' do
      let(:status) { 502 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception Faraday::ServerError }
    end

    context 'with unparseable response' do
      let :body do
        file_fixture('jsonapi/multiple_invalid_relationship.json').read
      end

      it 'raises descriptive exception' do
        expect { request }.to raise_exception \
          described_class::UnparseableResponseError,
          %r{Error parsing #{api_endpoint}/mock_entities with headers:}
      end
    end
  end
end
