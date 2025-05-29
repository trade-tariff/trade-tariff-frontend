FactoryBot.define do
  factory :duty_calculator_rules_of_origin_proof, class: 'DutyCalculator::RulesOfOrigin::Proof' do
    sequence(:summary) { |n| "Proof summary #{n}" }
    url { 'https://www.gov.uk/' }
    sequence(:subtext) { |n| "Proof subtext #{n}" }
    content { "First paragraph\n\nSecond paragraph" }
  end
end
