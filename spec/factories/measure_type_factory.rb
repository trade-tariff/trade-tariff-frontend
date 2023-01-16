FactoryBot.define do
  factory :measure_type do
    id { Forgery(:basic).text(exactly: 3) }
    description { Forgery(:basic).text }

    trait :vat do
      id { '305' }
      description { 'VAT' }
    end

    trait :excise do
      id { '305' }
    end

    trait :vat_excise do
      id { '305' }
    end

    trait :suspension do
      id { '112' }
    end

    trait :credibility_check do
      id { '481' }
    end

    trait :import_controls do
      id { '277' }
    end

    trait :trade_remedies do
      id { '551' }
    end

    trait :quotas do
      id { '122' }
    end

    trait :third_country do
      id { '103' }
    end

    trait :tariff_preference do
      id { '142' }
    end

    trait :other_customs_duties do
      id { '109' }
    end

    trait :excluded do
      id { '430' }
    end

    trait :unclassified do
      id { 'FOO' }
    end

    trait :import_export_supplementary do
      id { '109' }
    end

    trait :import_only_supplementary do
      id { '110' }
    end

    trait :export_only_supplementary do
      id { '111' }
    end

    trait :prohibitive do
      measure_type_series_id { 'A' }
    end

    trait :unclassified_import_control do
      measure_component_applicable_code { 2 }
    end

    trait :unclassified_customs_duties do
      measure_component_applicable_code { 1 }
    end

    trait :safeguard do
      id { MeasureType::SAFEGUARD_TYPES.first }
    end
  end
end
