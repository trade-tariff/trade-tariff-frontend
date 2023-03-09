require 'spec_helper'

RSpec.describe Beta::Search::SearchResult do
  subject(:search_result) { build(:search_result) }

  let(:expected_relationships) do
    %i[
      chapter_statistics
      heading_statistics
      facet_filter_statistics
      hits
      direct_hit
      guide
      search_query_parser_result
      intercept_message
    ]
  end

  it do
    expect(search_result).to have_attributes(took: 2,
                                             timed_out: false,
                                             max_score: 76.975296,
                                             total_results: 1097)
  end

  it { expect(described_class.relationships).to eq(expected_relationships) }

  describe '#facet_filter_statistics' do
    subject(:facet_filter_statistics) do
      build(
        :search_result,
        :with_facet_filter_statistics_above_and_below_threshold,
      ).facet_filter_statistics
    end

    it { is_expected.to all(be_a(Beta::Search::FacetFilterStatistic)) }
    it { expect(facet_filter_statistics.count).to eq(1) }
  end

  describe '#multiple_headings_view?' do
    context 'when the are multiple headings' do
      subject(:search_result) { build(:search_result, :multiple_headings_view) }

      it { is_expected.to be_multiple_headings_view }
    end

    context 'when the are not multiple headings' do
      subject(:search_result) { build(:search_result) }

      it { is_expected.not_to be_multiple_headings_view }
    end
  end

  describe '#classification_for' do
    context 'when the are matching classifications' do
      subject(:classification_for) { build(:search_result).classification_for(:material, 'leather') }

      it { is_expected.to be_a(Beta::Search::FacetClassificationStatistic) }
    end

    context 'when the are no matching classifications' do
      subject(:classification_for) { build(:search_result).classification_for(:material, 'cotton') }

      it { is_expected.to be_nil }
    end

    context 'when there are no classifications' do
      subject(:classification_for) { build(:search_result, :no_facets).classification_for(:material, 'leather') }

      it { is_expected.to be_nil }
    end
  end

  describe '#spelling_corrected?' do
    it { expect(search_result.spelling_corrected?).to eq(search_result.search_query_parser_result.spelling_corrected?) }
  end

  describe '#original_search_query' do
    it { expect(search_result.original_search_query).to eq(search_result.search_query_parser_result.original_search_query) }
  end

  describe '#corrected_search_query' do
    it { expect(search_result.corrected_search_query).to eq(search_result.search_query_parser_result.corrected_search_query) }
  end
end
