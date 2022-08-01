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
end
