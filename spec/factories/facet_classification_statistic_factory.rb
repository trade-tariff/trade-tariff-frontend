FactoryBot.define do
  factory :facet_classification_statistic, class: 'Beta::Search::FacetClassificationStatistic' do
    facet { 'animal_type' }
    count { 7 }
    classification { 'swine' }

    trait :garment_type do
      facet { 'garment_type' }
      classification { 'trousers and shorts' }
    end

    trait :material do
      facet { 'material' }
      classification { 'leather' }
    end
  end
end
