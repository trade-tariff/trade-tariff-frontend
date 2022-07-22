FactoryBot.define do
  factory :rules_of_origin_rule_set, class: 'RulesOfOrigin::RuleSet' do
    transient do
      rule_count { 2 }
    end

    sequence(:resource_id) { |n| "abcdef#{n}" }
    sequence(:heading) { |n| sprintf 'Heading %03d0-%03d9', n, n }
    subdivision { '' }
    rules { attributes_for_list :rules_of_origin_v2_rule, rule_count }

    trait :subdivided do
      heading { 'Heading 1000-1999' }
      sequence(:subdivision) { |n| "Subdivision #{n}" }
    end
  end
end
