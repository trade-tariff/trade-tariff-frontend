FactoryBot.define do
  factory :duty_calculator_rules_of_origin_link, class: 'DutyCalculator::RulesOfOrigin::Link' do
    sequence(:text) { |n| "GovUK page #{n}" }
    url { 'https://www.gov.uk' }
  end
end
