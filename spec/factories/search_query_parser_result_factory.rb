FactoryBot.define do
  factory :search_query_parser_result, class: 'Beta::Search::SearchQueryParserResult' do
    corrected_search_query { 'clothing set' }
    original_search_query { 'cloting set' }
    verbs { [] }
    adjectives { [] }
    nouns { ['clothing set'] }
    noun_chunks { ['clothing set'] }
  end
end
