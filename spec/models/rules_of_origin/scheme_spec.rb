require 'spec_helper'

describe RulesOfOrigin::Scheme do
  let(:api_host) { TradeTariffFrontend::ServiceChooser.api_host }
  let(:response_headers) { { content_type: 'application/json; charset=utf-8' } }

  it { is_expected.to respond_to :scheme_code }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :countries }
  it { is_expected.to respond_to :footnote }
  it { is_expected.to respond_to :fta_intro }
  it { is_expected.to respond_to :introductory_notes }
  it { is_expected.to respond_to :rules }
  it { is_expected.to respond_to :links }

  describe '.all' do
    let(:json_response) { response_data.to_json }

    let :response_data do
      {
        data: [
          {
            id: 'EU',
            type: 'rules_of_origin_scheme',
            attributes: {
              scheme_code: 'EU',
              title: 'Scheme title',
              countries: %w[FR ES IT],
              footnote: 'Footnote comments **in markdown**',
              fta_intro: "## Markdown heading\n\n Further information",
              introductory_notes: "## Introductory notes\n\ndetails",
            },
            relationships: {
              rules: {
                data: [
                  {
                    id: '1',
                    type: 'rules_of_origin_rule',
                  },
                ],
              },
              links: {
                data: [
                  {
                    id: 'EU-link-1',
                    type: 'rules_of_origin_link',
                  },
                ],
              },
            },
          },
        ],
        included: [
          {
            id: '1',
            type: 'rules_of_origin_rule',
            attributes: {
              id_rule: 1,
              heading: 'Chapter 22',
              description: 'Beverages',
              rule: "Rule\n\n* Requirement 1\n* Requirement 2",
            },
          },
          {
            id: 'EU-link-1',
            type: 'rules_of_origin_link',
            attributes: {
              text: 'GovUK',
              url: 'https://www.gov.uk',
            },
          },
        ],
      }
    end

    shared_context 'with mocked response' do
      subject(:schemes) { described_class.all('1905310101', 'FR') }

      before do
        stub_request(:get, "#{api_host}/rules_of_origin_schemes")
          .with(query: { heading_code: '190531', country_code: 'FR' })
          .to_return(body: json_response, status: 200, headers: response_headers)
      end
    end

    context 'without codes' do
      it 'will raise an exception' do
        expect { described_class.all }.to raise_exception ArgumentError
      end
    end

    context 'with codes' do
      include_context 'with mocked response'

      it { is_expected.to have_attributes length: 1 }
      it { is_expected.to all be_instance_of described_class }

      context 'with first scheme' do
        subject(:scheme) { schemes.first }

        it { is_expected.to have_attributes scheme_code: 'EU' }
        it { is_expected.to have_attributes title: 'Scheme title' }
        it { is_expected.to have_attributes countries: %w[FR ES IT] }
        it { is_expected.to have_attributes footnote: /footnote/i }
        it { is_expected.to have_attributes fta_intro: /Further information/ }
        it { is_expected.to have_attributes introductory_notes: /Introductory notes/ }
        it { expect(scheme.rules).to have_attributes length: 1 }
      end

      context 'with first schemes rule do' do
        subject { schemes.first.rules.first }

        it { is_expected.to have_attributes id_rule: 1 }
        it { is_expected.to have_attributes heading: 'Chapter 22' }
        it { is_expected.to have_attributes description: 'Beverages' }
        it { is_expected.to have_attributes rule: /\* Requirement 1/ }
      end
    end

    context 'with additional params' do
      subject(:schemes) { described_class.all('190531', 'FR', page: 1) }

      before do
        allow(described_class).to receive(:api).and_return api_instance
        allow(api_instance).to receive(:get).and_call_original

        stub_request(:get, "#{api_host}/rules_of_origin_schemes")
          .with(query: { heading_code: '190531', country_code: 'FR', page: 1 })
          .to_return(body: json_response, status: 200, headers: response_headers)
      end

      let(:api_instance) { described_class.api }

      it 'combines params' do
        schemes # trigger the query

        expect(api_instance).to have_received(:get)
          .with('/rules_of_origin_schemes',
                heading_code: '190531',
                country_code: 'FR',
                page: 1)
      end
    end

    context 'with full commodity code' do
      subject { described_class.all('1905310101', 'FR') }

      before do
        stub_request(:get, "#{api_host}/rules_of_origin_schemes")
          .with(query: { heading_code: '190531', country_code: 'FR' })
          .to_return(body: json_response, status: 200, headers: response_headers)
      end

      it { is_expected.to have_attributes length: 1 }
      it { is_expected.to all be_instance_of described_class }
    end

    context 'with empty response' do
      include_context 'with mocked response'

      let(:response_data) { { data: [], included: [] } }

      it { is_expected.to eql [] }
    end

    context 'with response with no rules or links' do
      include_context 'with mocked response'

      let :response_data do
        {
          data: [
            {
              id: 'EU',
              type: 'rules_of_origin_scheme',
              attributes: {
                scheme_code: 'EU',
                title: 'Scheme title',
                countries: %w[FR ES IT],
                footnote: 'Footnote comments **in markdown**',
              },
              relationships: {
                rules: {
                  data: [],
                  links: [],
                },
              },
            },
          ],
          included: [],
        }
      end

      it { is_expected.to have_attributes length: 1 }

      context 'with first scheme returned' do
        subject { schemes.first }

        it { is_expected.to have_attributes scheme_code: 'EU' }
        it { is_expected.to have_attributes rules: [] }
        it { is_expected.to have_attributes links: [] }
      end
    end

    describe 'links' do
      include_context 'with mocked response'

      it { expect(schemes.first.links.length).to be 1 }

      context 'with single link' do
        subject { schemes.first.links.first }

        it { is_expected.to have_attributes text: 'GovUK' }
        it { is_expected.to have_attributes url: 'https://www.gov.uk' }
      end
    end
  end
end
