FactoryBot.define do
  factory :facet_filter_statistic, class: 'Beta::Search::FacetFilterStatistic' do
    facet_filter { 'material' }
    facet_count { 10 }
    display_name { 'Material' }
    question { 'What material?' }
    facet_classification_statistics do
      [
        attributes_for(:facet_classification_statistic, :material),
        attributes_for(:facet_classification_statistic, :garment_type),
      ]
    end
  end
end
