FactoryBot.define do
  sequence(:measure_sid, &:to_s)

  factory :duty_calculator_measure, class: 'DutyCalculator::Api::Measure' do
    transient do
      source { 'uk' }
      scheme_code {}
    end

    id { generate(:measure_sid) }
    effective_end_date {}
    effective_start_date {}
    excise { false }
    excluded_countries {}
    footnotes {}
    import {}
    legal_acts {}
    national_measurement_units {}
    origin {}
    reduction_indicator {}
    vat { false }
    meta do
      {
        'duty_calculator' => {
          'source' => source,
          'scheme_code' => scheme_code,
        },
      }
    end

    measure_type         { attributes_for :duty_calculator_measure_type }
    geographical_area    { attributes_for :duty_calculator_geographical_area }
    duty_expression      { attributes_for :duty_calculator_duty_expression }
    order_number         { attributes_for :duty_calculator_order_number }
    additional_code      {}
    suspension_legal_act {}

    measure_conditions { [] }
    measure_components { [] }
    resolved_measure_components { [] }

    trait :autonomous do
      measure_type { attributes_for :duty_calculator_measure_type, :autonomous }
    end

    trait :autonomous_end_use do
      measure_type { attributes_for :duty_calculator_measure_type, :autonomous_end_use }
    end

    trait :certain_category_goods do
      measure_type { attributes_for :duty_calculator_measure_type, :certain_category_goods }
    end

    trait :airworthiness do
      measure_type { attributes_for :duty_calculator_measure_type, :airworthiness }
    end

    trait :preferential_suspension do
      measure_type { attributes_for :duty_calculator_measure_type, :preferential_suspension }
    end

    trait :non_preferential do
      measure_type { attributes_for :duty_calculator_measure_type, :non_preferential }
    end

    trait :non_preferential_end_use do
      measure_type { attributes_for :duty_calculator_measure_type, :non_preferential_end_use }
    end

    trait :tariff_preference do
      measure_type { attributes_for :duty_calculator_measure_type, :tariff_preference }
      scheme_code { 'eu' }
    end

    trait :preferential do
      measure_type { attributes_for :duty_calculator_measure_type, :preferential }
      scheme_code { 'albania' }
    end

    trait :preferential_end_use do
      measure_type { attributes_for :duty_calculator_measure_type, :preferential_end_use }
      scheme_code { 'andean' }
    end

    trait :customs_union do
      measure_type { attributes_for :duty_calculator_measure_type, :customs_union }
      scheme_code { 'albania' }
    end

    trait :vat do
      measure_type { attributes_for :duty_calculator_measure_type, :vat }
      vat { true }
    end

    trait :excise do
      measure_type { attributes_for :duty_calculator_measure_type, :excise }
      excise { true }
    end

    trait :authorised_use_provisions_submission do
      measure_type { attributes_for :duty_calculator_measure_type, :authorised_use_provisions_submission }

      measure_conditions do
        [
          attributes_for(:duty_calculator_measure_condition, :declaration_document_present),
          attributes_for(:duty_calculator_measure_condition, :declaration_document_not_present),
        ]
      end
    end

    trait :provisional_anti_dumping do
      measure_type { attributes_for :duty_calculator_measure_type, :provisional_anti_dumping }
    end

    trait :definitive_anti_dumping do
      measure_type { attributes_for :duty_calculator_measure_type, :definitive_anti_dumping }
    end

    trait :provisional_countervailing do
      measure_type { attributes_for :duty_calculator_measure_type, :provisional_countervailing }
    end

    trait :definitive_countervailing do
      measure_type { attributes_for :duty_calculator_measure_type, :definitive_countervailing }
    end

    trait :additional_duties do
      measure_type { attributes_for :duty_calculator_measure_type, :additional_duties }
    end

    trait :additional_duties_safeguard do
      measure_type { attributes_for :duty_calculator_measure_type, :additional_duties_safeguard }
    end

    trait :third_country_tariff do
      measure_type { attributes_for :duty_calculator_measure_type, :third_country }
    end

    trait :third_country_tariff_authorised_use do
      measure_type { attributes_for :duty_calculator_measure_type, :third_country_authorised_use }
    end

    trait :tariff_preference do
      measure_type { attributes_for :duty_calculator_measure_type, :tariff_preference }
    end

    trait :provisional_anti_dumping do
      measure_type { attributes_for :duty_calculator_measure_type, :provisional_anti_dumping }
    end

    trait :with_resolved_duty_expression do
      resolved_duty_expression do
        "<span>9.00</span> % <strong>+ <span>0.00</span> EUR / <abbr title='Hectokilogram'>100 kg</abbr></strong> MAX <span>24.20</span> % <strong>+ <span>0.00</span> EUR / <abbr title='Hectokilogram'>100 kg</abbr></strong>"
      end
    end

    trait :with_stopping_conditions do
      measure_conditions do
        [
          attributes_for(:duty_calculator_measure_condition, :stopping_document),
          attributes_for(:duty_calculator_measure_condition, :stopping_negative),
        ]
      end
    end

    trait :with_compound_measure_components do
      duty_expression do
        attributes_for(:duty_calculator_duty_expression, :alcohol_volume_measure_unit)
      end

      measure_components do
        [
          attributes_for(:duty_calculator_measure_component, :alcohol_volume),
          attributes_for(:duty_calculator_measure_component, :alcohol_volume),
        ]
      end
    end

    trait :with_sucrose_measure_components do
      duty_expression do
        attributes_for(:duty_calculator_duty_expression, :sucrose_measure_unit)
      end

      measure_components do
        [
          attributes_for(:duty_calculator_measure_component, :sucrose),
        ]
      end
    end

    trait :with_euro_measure_unit_measure_component do
      duty_expression do
        attributes_for(:duty_calculator_duty_expression, :euro_measure_unit)
      end

      measure_components do
        [
          attributes_for(:duty_calculator_measure_component, :with_measure_units, :euros),
        ]
      end
    end

    trait :with_pounds_measure_unit_measure_component do
      duty_expression do
        attributes_for(:duty_calculator_duty_expression, :pounds_measure_unit)
      end

      measure_components do
        [
          attributes_for(:duty_calculator_measure_component, :with_measure_units, :pounds),
        ]
      end
    end

    trait :with_excise_measure_components do
      measure_components do
        [
          attributes_for(:duty_calculator_measure_component, :with_retail_price_measure_units),
          attributes_for(:duty_calculator_measure_component, :with_mil_measure_units),
        ]
      end
    end

    trait :with_condition_measure_units do
      measure_conditions do
        [
          attributes_for(:duty_calculator_measure_condition, :with_measure_units),
        ]
      end
    end
  end
end
