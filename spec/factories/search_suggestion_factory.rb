FactoryBot.define do
  factory :search_suggestion do
    value { 'test' }
    score { 0.1124 }
    query { 'test' }
  end
end
