FactoryBot.define do
  factory :news_collection, class: 'News::Collection' do
    sequence(:resource_id, &:to_s)
    sequence(:name) { |n| "Collection #{n}" }
    sequence(:slug) { |n| "collection_#{n}" }
    priority { 0 }
    description { 'This is a description' }
  end
end
