FactoryBot.define do
  factory :rules_of_origin_link, class: 'RulesOfOrigin::Link' do
    sequence(:text) { |n| "GovUK page #{n}" }
    url { 'https://www.gov.uk' }
  end
end
