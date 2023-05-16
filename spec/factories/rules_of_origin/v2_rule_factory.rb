FactoryBot.define do
  factory :rules_of_origin_v2_rule, class: 'RulesOfOrigin::V2Rule' do
    sequence(:resource_id) { |n| "abcdef#{n}" }
    sequence(:rule) { |n| "Rule #{n}" }
    rule_class { [] }

    trait :wholly_obtained do
      rule_class { %w[WO] }
    end

    trait :with_markdown do
      rule { '[Chapter&nbsp;1](/some/where)' }
    end

    trait :with_footnote do
      footnotes { ['This is a **footnote**'] }
    end
  end
end
