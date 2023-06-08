require 'spec_helper'

RSpec.describe RulesOfOrigin::Scheme do
  let(:api_host) { TradeTariffFrontend::ServiceChooser.api_host }
  let(:response_headers) { { content_type: 'application/json; charset=utf-8' } }
  let(:cumulation_methods) { { 'bilateral' => %w[GB CA], 'extended' => %w[EU AD] } }
  let :response_data do
    {
      data: [
        {
          id: 'EU',
          type: 'rules_of_origin_scheme',
          attributes: {
            scheme_code: 'EU',
            title: 'Scheme title',
            unilateral: true,
            countries: %w[FR ES IT],
            footnote: 'Footnote comments **in markdown**',
            fta_intro: "## Markdown heading\n\n Further information",
            introductory_notes: "## Introductory notes\n\ndetails",
            cumulation_methods:,
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
            origin_reference_document: {
              data: {
                id: 'origin_reference_document_id',
                type: 'rules_of_origin_origin_reference_document',
              },
            },
            proofs: {
              data: [
                {
                  id: 'proof-1',
                  type: 'rules_of_origin_proof',
                },
              ],
            },
            articles: {
              data: [
                {
                  id: 'EU/test-article',
                  type: 'rules_of_origin_article',
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
            source: 'scheme',
          },
        },
        {
          id: 'proof-1',
          type: 'rules_of_origin_proof',
          attributes: {
            summary: 'proof',
            url: 'https://www.gov.uk/',
            subtext: 'subtext',
          },
        },
        {
          id: 'EU/test-article',
          type: 'rules_of_origin_article',
          attributes: {
            article: 'test-article',
            content: 'Hello',
          },
        },
        {
          id: 'origin_reference_document_id',
          type: 'rules_of_origin_origin_reference_document',
          attributes: {
            ord_date: '28 December 2021',
            ord_original: '211203_ORD_Japan_V1.1.odt',
            ord_title: 'Origin Reference Document title',
            ord_version: '1.1',
          },
        },
      ],
    }
  end

  it { is_expected.to respond_to :scheme_code }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :countries }
  it { is_expected.to respond_to :footnote }
  it { is_expected.to respond_to :unilateral }
  it { is_expected.to respond_to :fta_intro }
  it { is_expected.to respond_to :introductory_notes }
  it { is_expected.to respond_to :rules }
  it { is_expected.to respond_to :links }
  it { is_expected.to respond_to :articles }
  it { is_expected.to respond_to :rule_sets }
  it { is_expected.to respond_to :origin_reference_document }
  it { is_expected.to respond_to :cumulation_methods }
  it { is_expected.to respond_to :proof_intro }
  it { is_expected.to respond_to :proof_codes }

  describe '.for_heading_and_country' do
    shared_context 'with mocked response' do
      subject(:schemes) { described_class.for_heading_and_country('1905310101', 'FR') }

      before do
        stub_request(:get, "#{api_host}/rules_of_origin_schemes")
          .with(query: { heading_code: '190531', country_code: 'FR' })
          .to_return(body: response_data.to_json, status: 200, headers: response_headers)
      end
    end

    context 'without codes' do
      it 'will raise an exception' do
        expect { described_class.for_heading_and_country }.to raise_exception ArgumentError
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
        it { is_expected.to have_attributes unilateral: true }
        it { is_expected.to have_attributes footnote: /footnote/i }
        it { is_expected.to have_attributes fta_intro: /Further information/ }
        it { is_expected.to have_attributes introductory_notes: /Introductory notes/ }
        it { is_expected.to have_attributes cumulation_methods: }
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
      subject(:schemes) { described_class.for_heading_and_country('190531', 'FR', page: 1) }

      before do
        allow(described_class).to receive(:api).and_return api_instance
        allow(api_instance).to receive(:get).and_call_original

        stub_request(:get, "#{api_host}/rules_of_origin_schemes")
          .with(query: { heading_code: '190531', country_code: 'FR', page: 1 })
          .to_return(body: response_data.to_json, status: 200, headers: response_headers)
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
      subject { described_class.for_heading_and_country('1905310101', 'FR') }

      before do
        stub_request(:get, "#{api_host}/rules_of_origin_schemes")
          .with(query: { heading_code: '190531', country_code: 'FR' })
          .to_return(body: response_data.to_json, status: 200, headers: response_headers)
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

    describe '.with_rules_for_commodity' do
      subject { described_class.with_rules_for_commodity commodity }

      before do
        stub_request(:get, "#{api_host}/rules_of_origin_schemes/#{commodity.to_param}")
          .to_return(body: response_data.to_json, status: 200, headers: response_headers)
      end

      let(:commodity) { build :commodity }

      it { is_expected.to have_attributes length: 1 }
      it { is_expected.to all be_instance_of described_class }
    end

    describe '.with_duty_drawback_articles' do
      subject { described_class.with_duty_drawback_articles }

      before do
        stub_request(:get, "#{api_host}/rules_of_origin_schemes?filter[has_article]=duty-drawback")
          .to_return(body: response_data.to_json, status: 200, headers: response_headers)
      end

      it { is_expected.to have_attributes length: 1 }
      it { is_expected.to all be_instance_of described_class }
    end

    describe '#links' do
      include_context 'with mocked response'

      it { expect(schemes.first.links.length).to be 1 }

      context 'with first link' do
        subject { schemes.first.links.first }

        it { is_expected.to have_attributes text: 'GovUK' }
        it { is_expected.to have_attributes url: 'https://www.gov.uk' }
        it { is_expected.to have_attributes source: 'scheme' }
      end
    end

    describe '#agreement_link' do
      context 'when link source is scheme' do
        include_context 'with mocked response'

        it { expect(schemes.first.agreement_link).to eq 'https://www.gov.uk' }
      end

      context 'when link source is scheme set' do
        include_context 'with mocked response'

        before { schemes.first.links.first.source = 'scheme_set' }

        it { expect(schemes.first.agreement_link).to eq nil }
      end

      context 'when no links exist' do
        include_context 'with mocked response'

        before { schemes.first.links = [] }

        it { expect(schemes.first.agreement_link).to eq nil }
      end
    end

    describe '#proofs' do
      include_context 'with mocked response'

      it { expect(schemes.first.proofs.length).to be 1 }

      context 'with first proof' do
        subject { schemes.first.proofs.first }

        it { is_expected.to have_attributes summary: 'proof' }
        it { is_expected.to have_attributes url: 'https://www.gov.uk/' }
        it { is_expected.to have_attributes subtext: 'subtext' }
      end
    end

    describe '#articles' do
      include_context 'with mocked response'

      it { expect(schemes.first.articles.length).to be 1 }

      context 'with first article' do
        subject { schemes.first.articles.first }

        it { is_expected.to have_attributes article: 'test-article' }
        it { is_expected.to have_attributes content: 'Hello' }
      end
    end

    describe '#origin_reference_document' do
      include_context 'with mocked response'

      it { expect(schemes.first.origin_reference_document).to be_instance_of RulesOfOrigin::OriginReferenceDocument }

      context 'with origin reference document' do
        subject { schemes.first.origin_reference_document }

        it { is_expected.to have_attributes ord_title: 'Origin Reference Document title' }
        it { is_expected.to have_attributes ord_date: '28 December 2021' }
        it { is_expected.to have_attributes ord_original: '211203_ORD_Japan_V1.1.odt' }
        it { is_expected.to have_attributes ord_version: '1.1' }
      end
    end
  end

  describe '#article' do
    let(:scheme) { build(:rules_of_origin_scheme) }

    context 'with matching article' do
      subject { scheme.article scheme.articles.first.article }

      it { is_expected.to have_attributes article: scheme.articles.first.article }
    end

    context 'with non matching article' do
      subject { scheme.article 'unknown-missing' }

      it { is_expected.to be_nil }
    end
  end

  describe '#v2_rules' do
    subject(:v2_rules) { scheme.v2_rules }

    let(:scheme) { build(:rules_of_origin_scheme, rule_set_count: 2, v2_rule_count: 3) }

    it { is_expected.to have_attributes length: 6 }

    describe 'rule content' do
      subject { v2_rules.fourth.rule }

      it { is_expected.to eql scheme.rule_sets[1].rules[0].rule }
    end
  end

  describe '#proof_codes' do
    subject { described_class.new }

    it { is_expected.to have_attributes proof_codes: {} }
  end
end
