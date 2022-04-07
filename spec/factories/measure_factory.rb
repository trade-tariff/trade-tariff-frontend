FactoryBot.define do
  factory :measure do
    transient do
      measure_type_description { Forgery(:basic).text }
      measure_type_id { Forgery(:basic).text }
      geographical_area_id { 'FR' }
    end

    origin { %w[eu uk].sample }
    effective_start_date { Time.zone.today.ago(3.years).to_s }
    effective_end_date { nil }
    universal_waiver_applies { false }

    measure_type do
      attributes_for(:measure_type, id: measure_type_id, description: measure_type_description)
    end

    geographical_area do
      attributes_for(:geographical_area, id: geographical_area_id)
    end

    trait :vat do
      vat { true }
    end

    trait :erga_omnes do
      geographical_area { attributes_for(:geographical_area, :erga_omnes) }
    end

    trait :vat_excise do
      measure_type do
        attributes_for(:measure_type, :vat_excise, description: measure_type_description)
      end
    end

    trait :trade_remedies do
      measure_type do
        attributes_for(:measure_type, :trade_remedies, description: measure_type_description)
      end
    end

    trait :import_controls do
      measure_type do
        attributes_for(:measure_type, :import_controls, description: measure_type_description)
      end
    end

    trait :quotas do
      measure_type do
        attributes_for(:measure_type, :quotas, description: measure_type_description)
      end
    end

    trait :third_country do
      measure_type do
        attributes_for(:measure_type, :third_country, description: measure_type_description)
      end
      geographical_area { attributes_for(:geographical_area, :erga_omnes) }
    end

    trait :tariff_preference do
      measure_type do
        attributes_for(:measure_type, :tariff_preference, description: measure_type_description)
      end
    end

    trait :other_customs_duties do
      measure_type do
        attributes_for(:measure_type, :other_customs_duties, description: measure_type_description)
      end
    end

    trait :excluded do
      measure_type do
        attributes_for(:measure_type, :excluded, description: measure_type_description).stringify_keys
      end
    end

    trait :unclassified do
      measure_type do
        attributes_for(:measure_type, :unclassified, description: measure_type_description).stringify_keys
      end
    end

    trait :unclassified_import_control do
      measure_type do
        attributes_for(:measure_type, :unclassified, :unclassified_import_control, description: measure_type_description).stringify_keys
      end
    end

    trait :unclassified_customs_duties do
      measure_type do
        attributes_for(:measure_type, :unclassified, :unclassified_customs_duties, description: measure_type_description).stringify_keys
      end
    end

    trait :import_export_supplementary do
      measure_type do
        attributes_for(:measure_type, :import_export_supplementary, description: measure_type_description)
      end

      duty_expression do
        attributes_for(:duty_expression, base: 'p/st')
      end
    end

    trait :import_only_supplementary do
      measure_type do
        attributes_for(:measure_type, :import_only_supplementary, description: measure_type_description)
      end

      duty_expression do
        attributes_for(:duty_expression, base: 'p/st')
      end
    end

    trait :with_supplementary_measure_components do
      measure_components do
        [attributes_for(:measure_component, :with_supplementary_measurement_unit)]
      end
    end

    trait :with_eu_member_exclusions do
      excluded_countries do
        [
          { 'id' => 'AT', 'description' => 'Austria', 'geographical_area_id' => 'AT' },
          { 'id' => 'BE', 'description' => 'Belgium', 'geographical_area_id' => 'BE' },
          { 'id' => 'BG', 'description' => 'Bulgaria', 'geographical_area_id' => 'BG' },
          { 'id' => 'CH', 'description' => 'Switzerland', 'geographical_area_id' => 'CH' },
          { 'id' => 'CY', 'description' => 'Cyprus', 'geographical_area_id' => 'CY' },
          { 'id' => 'CZ', 'description' => 'Czechia', 'geographical_area_id' => 'CZ' },
          { 'id' => 'DE', 'description' => 'Germany', 'geographical_area_id' => 'DE' },
          { 'id' => 'DK', 'description' => 'Denmark', 'geographical_area_id' => 'DK' },
          { 'id' => 'EE', 'description' => 'Estonia', 'geographical_area_id' => 'EE' },
          { 'id' => 'ES', 'description' => 'Spain', 'geographical_area_id' => 'ES' },
          { 'id' => 'EU', 'description' => 'European Union', 'geographical_area_id' => 'EU' },
          { 'id' => 'FI', 'description' => 'Finland', 'geographical_area_id' => 'FI' },
          { 'id' => 'FR', 'description' => 'France', 'geographical_area_id' => 'FR' },
          { 'id' => 'GR', 'description' => 'Greece', 'geographical_area_id' => 'GR' },
          { 'id' => 'HR', 'description' => 'Croatia', 'geographical_area_id' => 'HR' },
          { 'id' => 'HU', 'description' => 'Hungary', 'geographical_area_id' => 'HU' },
          { 'id' => 'IE', 'description' => 'Ireland', 'geographical_area_id' => 'IE' },
          { 'id' => 'IS', 'description' => 'Iceland', 'geographical_area_id' => 'IS' },
          { 'id' => 'IT', 'description' => 'Italy', 'geographical_area_id' => 'IT' },
          { 'id' => 'LI', 'description' => 'Liechtenstein', 'geographical_area_id' => 'LI' },
          { 'id' => 'LT', 'description' => 'Lithuania', 'geographical_area_id' => 'LT' },
          { 'id' => 'LU', 'description' => 'Luxembourg', 'geographical_area_id' => 'LU' },
          { 'id' => 'LV', 'description' => 'Latvia', 'geographical_area_id' => 'LV' },
          { 'id' => 'MT', 'description' => 'Malta', 'geographical_area_id' => 'MT' },
          { 'id' => 'NL', 'description' => 'Netherlands', 'geographical_area_id' => 'NL' },
          { 'id' => 'NO', 'description' => 'Norway', 'geographical_area_id' => 'NO' },
          { 'id' => 'PL', 'description' => 'Poland', 'geographical_area_id' => 'PL' },
          { 'id' => 'PT', 'description' => 'Portugal', 'geographical_area_id' => 'PT' },
          { 'id' => 'RO', 'description' => 'Romania', 'geographical_area_id' => 'RO' },
          { 'id' => 'SE', 'description' => 'Sweden', 'geographical_area_id' => 'SE' },
          { 'id' => 'SI', 'description' => 'Slovenia', 'geographical_area_id' => 'SI' },
          { 'id' => 'SK', 'description' => 'Slovakia', 'geographical_area_id' => 'SK' },
        ]
      end
    end

    trait :with_exclusions do
      excluded_countries do
        [
          { 'id' => 'CH', 'description' => 'Switzerland', 'geographical_area_id' => 'CH' },
          { 'id' => 'CY', 'description' => 'Cyprus', 'geographical_area_id' => 'CY' },
          { 'id' => 'CZ', 'description' => 'Czechia', 'geographical_area_id' => 'CZ' },
        ]
      end
    end

    trait :specific_country do
      geographical_area { attributes_for(:geographical_area, :specific_country) }
    end

    trait :with_conditions do
      measure_conditions { [attributes_for(:measure_condition)] }
    end

    trait :with_conditions_with_guidance do
      measure_conditions do
        [
          attributes_for(:measure_condition),
          attributes_for(:measure_condition, :with_guidance),
        ]
      end
    end

    trait :with_permutations do
      measure_condition_permutation_groups do
        if respond_to?(:measure_conditions) && measure_conditions
          attributes_for_list :measure_condition_permutation_group, 1,
                              measure_conditions: measure_conditions
        else
          attributes_for_list :measure_condition_permutation_group, 1
        end
      end
    end

    trait :with_additional_code do
      additional_code { attributes_for(:additional_code) }
    end

    trait :with_footnotes do
      footnotes { [attributes_for(:footnote)] }
    end

    trait :national do
      origin { 'uk' }
    end

    trait :eu do
      origin { 'eu' }
    end

    trait :import do
      import { true }
    end

    trait :export do
      import { false }
    end

    trait :universal_waiver do
      universal_waiver_applies { true }
    end
  end
end
