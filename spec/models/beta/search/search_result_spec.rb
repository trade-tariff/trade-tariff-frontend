require 'spec_helper'

RSpec.describe Beta::Search::SearchResult do
  subject(:search_result) { build(:search_result) }

  let(:expected_relationships) do
    %i[chapter_statistics heading_statistics hits facet_filter_statistics guide search_query_parser_result]
  end

  it do
    expect(search_result).to have_attributes(took: 2,
                                             timed_out: false,
                                             max_score: 95.3,
                                             total_results: 10)
  end

  it { expect(described_class.relationships).to eq(expected_relationships) }
end
