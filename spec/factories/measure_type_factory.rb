FactoryBot.define do
  factory :measure_type do
    id { Forgery(:basic).text(exactly: 3) }
    description { Forgery(:basic).text }

    trait :vat do
      description { 'VAT' }
    end

    trait :vat_excise do
      id { '305' }
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

    trait :unclassified_import_control do
      measure_component_applicable_code { 2 }
    end

    trait :unclassified_customs_duties do
      measure_component_applicable_code { 1 }
    end
  end
end
