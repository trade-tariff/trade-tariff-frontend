FactoryBot.define do
  factory :facet_filter_statistic, class: 'Beta::Search::FacetFilterStatistic' do
    facet_filter { 'animal_type' }
    facet_count { 10 }
    display_name { 'Animal Type' }
    question { 'What animal type?' }
  end
end
