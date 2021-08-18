require 'spec_helper'

describe ProductSpecificRule do
  let(:api_host) { TradeTariffFrontend::ServiceChooser.api_host }
  let(:response_headers) { { content_type: 'application/json; charset=utf-8' } }

  describe '.all' do
    let :json_response do
      {
        data: [
          {
            id: '1',
            type: 'product_specific_rule',
            attributes: {
              heading: 'Chapter 22',
              description: 'Beverages',
              rule: "Rule\n\n* Requirement 1\n* Requirement 2",
            },
          },
        ],
      }.to_json
    end

    context 'without codes' do
      it 'will raise an exception' do
        expect { described_class.all }.to raise_exception ArgumentError
      end
    end

    context 'with codes' do
      subject(:rules) { described_class.all('190531', 'FR') }

      before do
        stub_request(:get, "#{api_host}/product_specific_rules")
          .with(query: { heading_code: '190531', country_code: 'FR' })
          .to_return(body: json_response, status: 200, headers: response_headers)
      end

      it { is_expected.to have_attributes length: 1 }
      it { is_expected.to all be_instance_of described_class }
      it { expect(rules.first.heading).to eql('Chapter 22') }
      it { expect(rules.first.description).to eql('Beverages') }
      it { expect(rules.first.rule).to match(/\* Requirement 1/) }
    end

    context 'with additional params' do
      subject(:rules) { described_class.all('190531', 'FR', page: 1) }

      before do
        allow(described_class).to receive(:api).and_return api_instance
        allow(api_instance).to receive(:get).and_call_original

        stub_request(:get, "#{api_host}/product_specific_rules")
          .with(query: { heading_code: '190531', country_code: 'FR', page: 1 })
          .to_return(body: json_response, status: 200, headers: response_headers)
      end

      let(:api_instance) { described_class.api }

      it 'combines params' do
        rules # trigger the query

        expect(api_instance).to have_received(:get)
          .with('/product_specific_rules',
                heading_code: '190531',
                country_code: 'FR',
                page: 1)
      end
    end

    context 'with full commodity code' do
      subject(:rules) { described_class.all('1905310101', 'FR') }

      before do
        stub_request(:get, "#{api_host}/product_specific_rules")
          .with(query: { heading_code: '190531', country_code: 'FR' })
          .to_return(body: json_response, status: 200, headers: response_headers)
      end

      it { is_expected.to have_attributes length: 1 }
      it { is_expected.to all be_instance_of described_class }
    end
  end
end
