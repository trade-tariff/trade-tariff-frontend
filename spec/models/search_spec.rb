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

  it 'strips [ and ] characters from search term' do
    search = described_class.new(q: '[hello] [world]')
    expect(search.q).to eq 'hello world'
  end

  describe 'raises on error if search responds with status 500' do
    subject(:perform_search) { described_class.new(q: 'abc').perform }

    before do
      stub_api_request('/search', :post).to_return jsonapi_error_response
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
end
