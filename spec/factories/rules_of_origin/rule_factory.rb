FactoryBot.define do
  factory :rules_of_origin_rule, class: 'RulesOfOrigin::Rule' do
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
