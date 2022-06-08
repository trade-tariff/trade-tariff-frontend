FactoryBot.define do
  factory :rules_of_origin_wizard_store, class: 'WizardSteps::Store' do
    initialize_with { new attributes.stringify_keys }

    transient do
      schemes { build_list :rules_of_origin_scheme, 2 }
      chosen_scheme { 1 }
    end

    service { 'uk' }
    country_code { 'JP' }
    commodity_code { '6004100091' }

    trait :with_chosen_scheme do
      available_scheme_codes { schemes.map(&:scheme_code) }
      scheme_code { schemes[chosen_scheme - 1].scheme_code }
    end

    trait :importing do
      with_chosen_scheme
      import_or_export { 'import' }
    end

    trait :exporting do
      with_chosen_scheme
      import_or_export { 'export' }
    end
  end
end
