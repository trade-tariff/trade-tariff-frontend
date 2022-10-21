FactoryBot.define do
  factory :news_collection do
    sequence(:id) { |n| n }
    sequence(:name) { |n| "Collection #{n}" }
  end
end
