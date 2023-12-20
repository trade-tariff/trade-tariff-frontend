FactoryBot.define do
  factory :commodity do
    transient do
      zero_mfn_duty { false }
    end

    heading { attributes_for(:heading) }
    chapter { attributes_for(:chapter) }
    section { attributes_for(:section) }
    description { Forgery(:basic).text }
    formatted_description { Forgery(:basic).text }
    description_plain { Forgery(:basic).text }
    validity_start_date { '2022-01-01T00:00:00.000Z' }
    sequence(:goods_nomenclature_sid) { |id| id }
    goods_nomenclature_item_id { sprintf '010130%04d', goods_nomenclature_sid }
    parent_sid { nil }
    producline_suffix { 80 }
    number_indents { 2 }
    meursing_code { false }
    declarable { true }
    has_chemicals { false }
    resource_type { 'commodity' }

    import_measures { [] }
    export_measures { [] }
    overview_measures { [] }
    import_trade_summary {}
    ancestors { [] }
    ancestor_descriptions { [] }

    meta do
      {
        'duty_calculator' => {
          'applicable_additional_codes' => {},
          'applicable_measure_units' => {},
          'applicable_vat_options' => {
            'VATZ' => 'VAT zero rate',
          },
          'entry_price_system' => false,
          'meursing_code' => false,
          'source' => 'uk',
          'trade_defence' => false,
          'zero_mfn_duty' => zero_mfn_duty,
        },
      }
    end

    trait :with_supplementary_unit do
      import_measures do
        [
          attributes_for(
            :measure,
            :excise,
            :erga_omnes,
            :with_supplementary_measure_components,
          ),
        ]
      end
    end

    trait :with_excise_supplementary_unit do
      import_measures do
        [
          attributes_for(
            :measure,
            :excise,
            :erga_omnes,
            :with_monetary_unit_measure_components,
          ),
        ]
      end
    end

    trait :with_a_vat_overview_measure do
      overview_measures do
        [
          attributes_for(:measure, :vat),
        ]
      end
    end

    trait :with_vat_overview_measures do
      overview_measures do
        [
          attributes_for(:measure, :vat),
          attributes_for(:measure, :vat),
        ]
      end
    end

    trait :with_third_country_overview_measures do
      overview_measures do
        [
          attributes_for(:measure, :third_country),
        ]
      end
    end

    trait :with_third_country_overview_measures_with_additional_codes do
      overview_measures do
        [
          attributes_for(:measure, :third_country, :with_additional_code),
          attributes_for(:measure, :third_country),
        ]
      end
    end

    trait :with_a_supplementary_unit_overview_measure do
      overview_measures do
        [
          attributes_for(:measure, :import_export_supplementary),
        ]
      end
    end

    trait :with_import_trade_summary do
      transient do
        preferential_tariff_duty { '10 %' }
        preferential_quota_duty {}
      end

      import_trade_summary do
        attributes_for(
          :import_trade_summary,
          preferential_tariff_duty:,
          preferential_quota_duty:,
        )
      end
    end

    trait :with_export_measures do
      export_measures do
        [
          attributes_for(:measure),
        ]
      end
    end

    trait :with_conditionally_prohibitive_measures do
      import_measures do
        [
          attributes_for(:measure, :conditionally_prohibitive),
        ]
      end
    end

    trait :with_prohibitive_measures do
      import_measures do
        [
          attributes_for(:measure, :prohibitive),
        ]
      end
    end

    trait :with_conditionally_prohibitive_and_prohibitive_measures do
      import_measures do
        [
          attributes_for(:measure, :prohibitive),
          attributes_for(:measure, :conditionally_prohibitive),
        ]
      end
    end

    trait :with_ancestors do
      ancestors do
        [
          attributes_for(:chapter, formatted_description: 'Live animals '),
          attributes_for(:heading, formatted_description: 'Live horses, asses, mules and hinnies '),
          attributes_for(:subheading, formatted_description: 'Horses'),
        ]
      end
    end

    trait :without_ancestors do
      ancestors { [] }
    end

    trait :with_ancestor_descriptions do
      description { 'Horses' }
      ancestor_descriptions { ['Live animals', 'Live horses, asses, mules and hinnies', 'Horses'] }
    end

    trait :with_other_ancestor_descriptions do
      description { 'Other' }
      ancestor_descriptions { ['Live animals', 'Live horses, asses, mules and hinnies', 'Other', 'Other', 'Other'] }
    end
  end
end
