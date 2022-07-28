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
      scheme_code { schemes[chosen_scheme - 1].scheme_code }
    end

    trait :import_only do
      import_only { true }
    end

    trait :importing do
      with_chosen_scheme
      import_or_export { 'import' }
    end

    trait :exporting do
      with_chosen_scheme
      import_or_export { 'export' }
    end

    trait :originating do
      with_chosen_scheme
      importing
    end

    trait :wholly_obtained do
      originating
      wholly_obtained { 'yes' }
    end

    trait :not_wholly_obtained do
      originating
      wholly_obtained { 'no' }
    end

    trait :sufficient_processing do
      not_wholly_obtained
      sufficient_processing { 'yes' }
    end

    trait :insufficient_processing do
      not_wholly_obtained
      sufficient_processing { 'no' }
    end

    trait :subdivided do
      schemes do
        build_list :rules_of_origin_scheme, 2, :subdivided
      end

      sufficient_processing
      subdivision_id { schemes.first.rule_sets.second.resource_id }
    end

    trait :meeting_psr do
      sufficient_processing
      rule { schemes.first.rule_sets.first.rules.first.resource_id }
    end

    trait :not_meeting_psr do
      sufficient_processing
      rule { 'none' }
    end
  end
end
