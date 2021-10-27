require 'spec_helper'

RSpec.describe ApiEntity do
  let :mock_entity do
    Class.new do
      include ApiEntity

      collection_path '/mock_entities'

      attr_accessor :name, :age

      has_many :parts, class_name: 'Part'

      def self.name
        'MockEntity'
      end
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

      it { is_expected.to have_attributes name: 'Joe', age: 21 }
    end

    context 'with 404 response' do
      let(:status) { 404 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception described_class::NotFound }
    end

    context 'with error response' do
      let(:status) { 500 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception described_class::Error }
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
      it { expect(request.first).to have_attributes name: 'Joe', age: 21 }
    end

    context 'with 404 response' do
      let(:status) { 404 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception described_class::NotFound }
    end

    context 'with error response' do
      let(:status) { 500 }
      let(:body) { {}.to_json }

      it { expect { request }.to raise_exception described_class::Error }
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
