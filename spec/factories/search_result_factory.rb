FactoryBot.define do
  factory :search_result, class: 'Beta::Search::SearchResult' do
    took  { 2 }
    timed_out { false }
    max_score { 95.3 }
    total_results { 10 }
  end
end
