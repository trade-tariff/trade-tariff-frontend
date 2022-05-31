FactoryBot.define do
  factory :rules_of_origin_wizard, class: 'WizardSteps::Store' do
    initialize_with { new attributes.stringify_keys }

    service { 'uk' }
    country_code { 'JP' }
    commodity_code { '6004100091' }
  end
end
