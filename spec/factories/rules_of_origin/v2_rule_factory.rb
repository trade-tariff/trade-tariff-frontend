FactoryBot.define do
  factory :rules_of_origin_v2_rule, class: 'RulesOfOrigin::V2Rule' do
    sequence(:resource_id) { |n| "abcdef#{n}" }
    sequence(:rule) { |n| "Rule #{n}" }
    rule_class { [] }

    trait :wholly_obtained do
      rule_class { %w[WO] }
    end
  end
end
