FactoryBot.define do
  factory :duty_calculator_rules_of_origin_rule, class: 'DutyCalculator::RulesOfOrigin::Rule' do
    sequence(:id_rule) { |n| n }
    sequence(:heading) { |n| "Chapter #{n}" }
    description { 'Description' }
    rule { 'Rule' }
    footnotes { [] }

    trait :with_footnote do
      footnotes { ['This is a footnote'] }
    end
  end
end
