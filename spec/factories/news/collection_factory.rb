FactoryBot.define do
  factory :news_collection, class: 'News::Collection' do
    sequence(:id) { |n| n }
    sequence(:name) { |n| "Collection #{n}" }
  end
end
