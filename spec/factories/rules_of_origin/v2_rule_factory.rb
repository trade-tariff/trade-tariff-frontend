FactoryBot.define do
  factory :rules_of_origin_v2_rule, class: 'RulesOfOrigin::V2Rule' do
    sequence(:rule) { |n| "Rule #{n}" }
    rule_class { [] }
  end
end
