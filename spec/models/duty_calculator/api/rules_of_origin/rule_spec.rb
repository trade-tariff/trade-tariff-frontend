RSpec.describe DutyCalculator::Api::RulesOfOrigin::Rule do
  it_behaves_like 'a resource that has attributes',
                  heading: 'Chapter&nbsp;7',
                  description: 'Edible vegetables and certain roots and tubers',
                  rule: 'Manufacture in which all the materials of Chapter 7 used are wholly obtained{{WO}}',
                  alternate_rule: ''
end
