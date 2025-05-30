FactoryBot.define do
  factory :duty_calculator_rules_of_origin_rule, class: 'DutyCalculator::Api::RulesOfOrigin::Rule' do
    heading { 'Chapter&nbsp;7' }
    description { 'Edible vegetables and certain roots and tubers' }
    rule { 'Manufacture in which all the materials of Chapter 7 used are wholly obtained{{WO}}' }
    alternate_rule { '' }
  end
end
