FactoryBot.define do
  factory :measure_type do
    id { Forgery(:basic).text(exactly: 3) }
    description { Forgery(:basic).text }
    semantic_roles { [] }

    trait :vat do
      id { '305' }
      description { 'VAT' }
    end

    trait :excise do
      id { '306' }
    end

    trait :vat_excise do
      id { '305' }
    end

    trait :suspension do
      id { '112' }
    end

    trait :credibility_check do
      id { '482' }
    end

    trait :import_controls do
      id { '277' }
    end

    trait :trade_remedies do
      id { '551' }
    end

    trait :quotas do
      id { '122' }
      semantic_roles { %w[provides_unit_context] }
    end

    trait :third_country do
      id { '103' }
      semantic_roles { %w[mfn_no_authorized_use provides_unit_context] }
    end

    trait :third_country_authorised_use do
      id { '105' }
      semantic_roles { %w[provides_unit_context] }
    end

    trait :tariff_preference do
      id { '142' }
      semantic_roles { %w[provides_unit_context cds_proofs_of_origin] }
    end

    trait :other_customs_duties do
      id { '109' }
      semantic_roles { %w[supplementary] }
    end

    trait :excluded do
      id { '430' }
    end

    trait :unclassified do
      id { 'FOO' }
    end

    trait :import_export_supplementary do
      id { '109' }
      semantic_roles { %w[supplementary] }
    end

    trait :import_only_supplementary do
      id { '110' }
      semantic_roles { %w[supplementary supplementary_unit_import_only] }
    end

    trait :export_only_supplementary do
      id { '111' }
      semantic_roles { %w[supplementary] }
    end

    trait :prohibitive do
      measure_type_series_id { 'A' }
      semantic_roles { %w[prohibitive] }
    end

    trait :unclassified_import_control do
      measure_component_applicable_code { 2 }
    end

    trait :unclassified_customs_duties do
      measure_component_applicable_code { 1 }
    end

    trait :safeguard do
      id { '696' }
      semantic_roles { %w[safeguard] }
    end
  end
end
