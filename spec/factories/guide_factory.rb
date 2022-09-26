FactoryBot.define do
  factory :guide, class: 'Beta::Search::Guide' do
    title { 'Herbal medicines' }
    url { 'Get help to classify herbal medicines' }
    strapline { 'This is the guide for Herbal medicines' }
    image { 'medicines.png'}
  end
end
