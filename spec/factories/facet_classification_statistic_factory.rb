FactoryBot.define do
  factory :facet_classification_statistic, class: 'Beta::Search::FacetClassificationStatistic' do
    facet { 'animal_type' }
    count { 7 }
    classification { 'swine' }
  end
end
