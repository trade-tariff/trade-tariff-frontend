FactoryBot.define do
  factory :rules_of_origin_wizard_store, class: 'WizardSteps::Store' do
    initialize_with { new attributes.stringify_keys }

    transient do
      schemes { build_list :rules_of_origin_scheme, 2 }
    end

    service { 'uk' }
    country_code { 'JP' }
    commodity_code { '6004100091' }

    trait :first_scheme do
      scheme_count { schemes.length }
      scheme_code { schemes.first.scheme_code }
    end

    trait :importing do
      trait :first_scheme
      import_or_export { 'import' }
    end

    trait :exporting do
      trait :first_scheme
      import_or_export { 'export' }
    end
  end
end
