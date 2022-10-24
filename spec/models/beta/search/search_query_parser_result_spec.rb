require 'spec_helper'

RSpec.describe Beta::Search::SearchQueryParserResult do
  subject(:search_query_parser_result) { build(:search_query_parser_result) }

  it {
    expect(search_query_parser_result).to have_attributes(corrected_search_query: 'clothing set',
                                                          original_search_query: 'cloting set',
                                                          verbs: [],
                                                          adjectives: [],
                                                          nouns: ['clothing set'],
                                                          noun_chunks: ['clothing set'])
  }

  describe '#spelling_corrected?' do
    subject(:search_query_parser_result) do
      build(
        :search_query_parser_result,
        corrected_search_query:,
        original_search_query:,
      )
    end

    context 'when the original_search_query and the corrected_search_query are the same' do
      let(:original_search_query) { 'halbiut' }
      let(:corrected_search_query) { 'halbiut' }

      it { is_expected.not_to be_spelling_corrected }
    end

    context 'when the original_search_query and the corrected_search_query are different' do
      let(:original_search_query) { 'halbiut' }
      let(:corrected_search_query) { 'halibut' }

      it { is_expected.to be_spelling_corrected }
    end
  end
end
