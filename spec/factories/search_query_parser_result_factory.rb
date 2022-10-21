FactoryBot.define do
  factory :search_query_parser_result, class: 'Beta::Search::SearchQueryParserResult' do
    corrected_search_query { 'clothing set' }
    original_search_query { 'cloting set' }
    verbs { [] }
    adjectives { [] }
    nouns { ['clothing set'] }
    noun_chunks { ['clothing set'] }

    trait :corrected do
      corrected_search_query { 'halibut' }
      original_search_query { 'halbiut' }
      verbs { [] }
      adjectives { [] }
      nouns { %w[halibut] }
      noun_chunks {}
    end

    trait :not_corrected do
      corrected_search_query { 'halbiut' }
      original_search_query { 'halbiut' }
      verbs { [] }
      adjectives { [] }
      nouns { %w[halibut] }
      noun_chunks {}
    end
  end
end
