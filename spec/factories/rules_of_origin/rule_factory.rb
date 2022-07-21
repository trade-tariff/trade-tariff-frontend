FactoryBot.define do
  factory :rules_of_origin_rule, class: 'RulesOfOrigin::Rule' do
    sequence(:id_rule) { |n| n }
    sequence(:heading) { |n| "Chapter #{n}" }
    description { 'Description' }
    rule { 'Rule' }
  end
end
