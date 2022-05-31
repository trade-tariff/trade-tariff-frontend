FactoryBot.define do
  factory :rules_of_origin_wizard, class: 'WizardSteps::Store' do
    initialize_with { new attributes.stringify_keys }

    service { 'uk' }
    country_code { 'JP' }
    commodity_code { '6004100091' }

    trait :importing do
      import_or_export { 'import' }
    end

    trait :exporting do
      import_or_export { 'export' }
    end
  end
end
