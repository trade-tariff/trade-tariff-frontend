require 'spec_helper'

RSpec.describe Search do
  describe '#date' do
    subject(:search) do
      described_class.new(
        'q' => 'foo',
        'day' => '01',
        'month' => '02',
        'year' => '2021',
      )
    end

    it 'calls the TariffDate builder' do
      allow(TariffDate).to receive(:build).and_call_original

      search.date

      expect(TariffDate).to have_received(:build)
    end

    it { expect(search.date).to eq(Date.parse('2021-02-01')) }
  end

  describe '#country=' do
    context 'when country is present' do
      subject { described_class.new(country: 'am') }

      it { is_expected.to have_attributes country: 'AM' }
    end

    context 'when country is nil' do
      subject { described_class.new(q: 'foo').country }

      it { is_expected.to be_nil }
    end
  end

  it 'strips [ and ] characters from search term' do
    search = described_class.new(q: '[hello] [world]')
    expect(search.q).to eq 'hello world'
  end

  describe 'raises on error if search responds with status 500' do
    subject(:perform_search) { described_class.new(q: 'abc').perform }

    before do
      stub_api_request('search', :post).to_return jsonapi_error_response
    end

    it 'search' do
      expect { perform_search }.to raise_error Faraday::ServerError
    end
  end

  describe '#day_month_and_year_set?' do
    let(:search) { described_class.new }

    context 'when date components are set' do
      it 'returns true' do
        search.day = 1
        search.month = 12
        search.year = 2021

        expect(search.day_month_and_year_set?).to be true
      end
    end

    context 'when date components are empty' do
      it 'returns false' do
        expect(search.day_month_and_year_set?).to be false
      end
    end
  end

  describe '#contains_search_term?' do
    subject { described_class.new(q: search_term).contains_search_term? }

    context 'with search query' do
      let(:search_term) { 'testing123' }

      it { is_expected.to be true }
    end

    context 'without search query' do
      let(:search_term) { ' ' }

      it { is_expected.to be false }
    end
  end

  describe '#missing_search_term?' do
    subject { described_class.new(q: search_term).missing_search_term? }

    context 'with search query' do
      let(:search_term) { 'testing123' }

      it { is_expected.to be false }
    end

    context 'without search query' do
      let(:search_term) { ' ' }

      it { is_expected.to be true }
    end
  end

  describe '#search_term_is_commodity_code?' do
    subject { described_class.new(q: search_term).search_term_is_commodity_code? }

    context 'with commodity_code' do
      let(:search_term) { '0101191919' }

      it { is_expected.to be true }
    end

    context 'with commodity_code with whitespace' do
      let(:search_term) { ' 0101191919' }

      it { is_expected.to be true }
    end

    context 'with other code' do
      let(:search_term) { '010119191' }

      it { is_expected.to be false }
    end

    context 'with textual search term' do
      let(:search_term) { 'testing123' }

      it { is_expected.to be false }
    end

    context 'with no search term' do
      let(:search_term) { ' ' }

      it { is_expected.to be false }
    end
  end

  describe '#search_term_is_heading_code?' do
    subject { described_class.new(q: search_term).search_term_is_heading_code? }

    context 'with heading_code' do
      let(:search_term) { '0101' }

      it { is_expected.to be true }
    end

    context 'with heading_code with whitespace' do
      let(:search_term) { ' 0101' }

      it { is_expected.to be true }
    end

    context 'with other code' do
      let(:search_term) { '010119191' }

      it { is_expected.to be false }
    end

    context 'with textual search term' do
      let(:search_term) { 'testing123' }

      it { is_expected.to be false }
    end

    context 'with no search term' do
      let(:search_term) { ' ' }

      it { is_expected.to be false }
    end
  end

  describe '#perform_v2_search request_id' do
    it 'sends request_id to the V2 search endpoint' do
      search = described_class.new(q: 'horses')
      search.request_id = 'test-uuid-456'

      stub = stub_api_request('search', :post).to_return(
        jsonapi_response(:search, {
          type: 'fuzzy_match',
          goods_nomenclature_match: { chapters: [], headings: [], commodities: [], sections: [] },
          reference_match: { chapters: [], headings: [], commodities: [], sections: [] },
        }),
      )

      search.perform

      expect(stub).to have_been_requested
    end
  end

  describe '#perform' do
    context 'when internal_search is true and INTERNAL_SEARCH_ENABLED is true' do
      subject(:perform_search) do
        search = described_class.new(q: 'horses')
        search.internal_search = true
        search.perform
      end

      let(:internal_response_body) do
        {
          'data' => [
            {
              'id' => '123',
              'type' => 'commodity',
              'attributes' => {
                'goods_nomenclature_item_id' => '0101210000',
                'producline_suffix' => '80',
                'goods_nomenclature_class' => 'Commodity',
                'description' => 'Pure-bred breeding animals',
                'formatted_description' => 'Pure-bred breeding animals',
                'declarable' => true,
                'score' => 12.5,
              },
            },
          ],
        }
      end

      before do
        allow(TradeTariffFrontend).to receive(:internal_search_enabled?).and_return(true)
        stub_api_request('search', :post, internal: true)
          .to_return(status: 200,
                     body: internal_response_body.to_json,
                     headers: { 'content-type' => 'application/json; charset=utf-8' })
      end

      it 'returns an InternalSearchResult' do
        expect(perform_search).to be_a(Search::InternalSearchResult)
      end

      it 'contains results' do
        expect(perform_search).to be_any
      end
    end

    context 'when internal_search is true and response is empty' do
      subject(:perform_search) do
        search = described_class.new(q: 'xyznonexistent')
        search.internal_search = true
        search.perform
      end

      before do
        allow(TradeTariffFrontend).to receive(:internal_search_enabled?).and_return(true)
        stub_api_request('search', :post, internal: true)
          .to_return(status: 200,
                     body: { 'data' => [] }.to_json,
                     headers: { 'content-type' => 'application/json; charset=utf-8' })
      end

      it 'returns an InternalSearchResult with none? true' do
        expect(perform_search).to be_none
      end
    end

    context 'when internal_search is false even though INTERNAL_SEARCH_ENABLED is true' do
      subject(:perform_search) { described_class.new(q: 'horses').perform }

      before do
        allow(TradeTariffFrontend).to receive(:internal_search_enabled?).and_return(true)
        stub_api_request('search', :post).to_return(
          jsonapi_response(:search, {
            type: 'fuzzy_match',
            goods_nomenclature_match: { chapters: [], headings: [], commodities: [], sections: [] },
            reference_match: { chapters: [], headings: [], commodities: [], sections: [] },
          }),
        )
      end

      it 'returns a Search::Outcome (falls back to V2)' do
        expect(perform_search).to be_a(Search::Outcome)
      end
    end

    context 'when INTERNAL_SEARCH_ENABLED is false' do
      subject(:perform_search) { described_class.new(q: 'horses').perform }

      before do
        allow(TradeTariffFrontend).to receive(:internal_search_enabled?).and_return(false)
        stub_api_request('search', :post).to_return(
          jsonapi_response(:search, {
            type: 'fuzzy_match',
            goods_nomenclature_match: { chapters: [], headings: [], commodities: [], sections: [] },
            reference_match: { chapters: [], headings: [], commodities: [], sections: [] },
          }),
        )
      end

      it 'returns a Search::Outcome' do
        expect(perform_search).to be_a(Search::Outcome)
      end
    end
  end
end
