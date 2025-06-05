FactoryBot.define do
  sequence(:goods_nomenclature_sid, &:to_s)

  factory :duty_calculator_commodity, class: 'DutyCalculator::Api::Commodity' do
    transient do
      applicable_measure_units { {} }
      applicable_additional_codes { {} }
      applicable_vat_options do
        {
          'VATR' => 'VAT reduced rate 5% (5.0)',
          'VATZ' => 'VAT zero rate (0.0)',
          'VAT' => 'Value added tax (20.0)',
        }
      end
      trade_defence { false }
      zero_mfn_duty { false }
      source { 'uk' }
    end

    meta do
      {
        'duty_calculator' => {
          'applicable_measure_units' => applicable_measure_units,
          'applicable_additional_codes' => applicable_additional_codes,
          'applicable_vat_options' => applicable_vat_options,
          'trade_defence' => trade_defence,
          'zero_mfn_duty' => zero_mfn_duty,
          'source' => source,
        },
      }
    end

    id { generate(:goods_nomenclature_sid) }
    producline_suffix { '80' }
    number_indents { 4 }
    description { 'Cherry tomatoes' }
    goods_nomenclature_item_id { '0702000007' }
    bti_url {}
    formatted_description { 'Cherry tomatoes' }
    description_plain { 'Cherry tomatoes' }
    consigned { false }
    consigned_from {}
    basic_duty_rate { '<span>8.00</span> %' }
    meursing_code { false }
    declarable { true }
    footnotes { [] }
    section {}
    chapter {}
    heading {}
    ancestors {}

    import_measures { [attributes_for(:duty_calculator_measure)] }
    export_measures { [] }

    trait :with_multiple_stopping_condition_measures do
      import_measures do
        [
          attributes_for(
            :duty_calculator_measure,
            :third_country_tariff,
            :with_stopping_conditions,
          ),
          attributes_for(
            :duty_calculator_measure,
            :third_country_tariff_authorised_use,
            :with_stopping_conditions,
          ),
        ]
      end
    end

    trait :with_measures do
      import_measures { [attributes_for(:duty_calculator_measure, :third_country_tariff)] }
    end

    trait :without_measures do
      import_measures { [] }
    end

    trait :with_compound_measure_units do
      import_measures do
        [
          attributes_for(
            :duty_calculator_measure,
            :third_country_tariff,
            :with_compound_measure_components,
          ),
        ]
      end

      applicable_measure_units do
        {
          'ASV' => {
            'measurement_unit_code' => 'ASV',
            'measurement_unit_qualifier_code' => nil,
            'unit' => 'percent',
            'multiplier' => nil,
            'coerced_measurement_unit_code' => nil,
            'original_unit' => nil,
          },
          'HLT' => {
            'measurement_unit_code' => 'HLT',
            'measurement_unit_qualifier_code' => nil,
            'unit' => 'litres',
            'multiplier' => '0.01',
            'coerced_measurement_unit_code' => 'LTR',
            'original_unit' => 'x 100 litres',
          },
          'LTR' => {
            'measurement_unit_code' => 'LTR',
            'measurement_unit_qualifier_code' => nil,
            'unit' => 'litres',
            'multiplier' => nil,
            'coerced_measurement_unit_code' => nil,
            'original_unit' => nil,
          },
        }
      end
    end

    trait :with_sucrose_measure_units do
      import_measures do
        [
          attributes_for(
            :duty_calculator_measure,
            :third_country_tariff,
            :with_sucrose_measure_components,
          ),
        ]
      end

      applicable_measure_units do
        {
          'DTN' => {
            'measurement_unit_code' => 'DTN',
            'measurement_unit_qualifier_code' => nil,
            'abbreviation' => '100 kg',
            'unit_question' => 'What is the weight of the goods you will be importing?',
            'unit_hint' => 'Enter the value in kilograms',
            'unit' => 'kilograms',
            'multiplier' => '0.01',
            'coerced_measurement_unit_code' => 'KGM',
            'original_unit' => 'x 100 kg',
          },
          'BRX' => {
            'measurement_unit_code' => 'BRX',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => '% sucrose',
            'unit_question' => 'What is the percentage of sucrose (Brix) in your goods?',
            'unit_hint' => 'If you do not know the percentage sucrose content (Brix value), check the footnotes for the commodity code to identify how to calculate it.',
            'unit' => '% sucrose',
          },
        }
      end
    end

    trait :with_compound_measure_units_no_multiplier do
      import_measures do
        [
          attributes_for(
            :duty_calculator_measure,
            :third_country_tariff,
            :with_compound_measure_components,
          ),
        ]
      end

      applicable_measure_units do
        {
          'ASV' => {
            'measurement_unit_code' => 'ASV',
            'measurement_unit_qualifier_code' => nil,
            'unit' => 'percent',
          },
          'HLT' => {
            'measurement_unit_code' => 'HLT',
            'measurement_unit_qualifier_code' => nil,
            'unit' => 'x 100 litres',
          },
        }
      end
    end

    trait :with_measure_units_with_multiplier do
      import_measures { [attributes_for(:duty_calculator_measure, :third_country_tariff, :with_pounds_measure_unit_measure_component)] }

      applicable_measure_units do
        {
          'DTN' => {
            'measurement_unit_code' => 'DTN',
            'measurement_unit_qualifier_code' => nil,
            'unit' => 'kilogrammes',
            'multiplier' => '0.01',
            'coerced_measurement_unit_code' => 'KGM',
            'original_unit' => 'x 100 kg',
          },
          'DTNR' => {
            'measurement_unit_code' => 'DTN',
            'measurement_unit_qualifier_code' => 'R',
            'unit' => 'kilogrammes',
            'multiplier' => '0.01',
            'coerced_measurement_unit_code' => 'KGM',
            'original_unit' => 'x 100 kg',
          },
        }
      end
    end

    trait :with_retail_price_measure_units do
      applicable_measure_units do
        {
          'RET' => {
            'measurement_unit_code' => 'RET',
            'measurement_unit_qualifier_code' => nil,
            'unit' => '£',
            'multiplier' => nil,
            'original_unit' => nil,
          },
        }
      end
    end

    trait :with_euro_measure_unit_measure_component do
      import_measures { [attributes_for(:duty_calculator_measure, :third_country_tariff, :with_euro_measure_unit_measure_component)] }

      applicable_measure_units do
        {
          'DTN' => {
            'measurement_unit_code' => 'DTN',
            'measurement_unit_qualifier_code' => nil,
            'unit' => 'x 100 kg',
          },
        }
      end
    end

    trait :with_pounds_measure_unit_measure_component do
      import_measures { [attributes_for(:duty_calculator_measure, :third_country_tariff, :with_pounds_measure_unit_measure_component)] }

      applicable_measure_units do
        {
          'DTN' => {
            'measurement_unit_code' => 'DTN',
            'measurement_unit_qualifier_code' => nil,
            'unit' => 'x 100 kg',
          },
        }
      end
    end

    trait :with_condition_measure_units do
      import_measures { [attributes_for(:duty_calculator_measure, :third_country_tariff, :with_condition_measure_units)] }

      applicable_measure_units do
        {
          'DTN' => {
            'measurement_unit_code' => 'DTN',
            'measurement_unit_qualifier_code' => nil,
            'unit' => 'x 100 kg',
          },
        }
      end
    end

    trait :with_excise_measures do
      import_measures do
        [
          attributes_for(:duty_calculator_measure, :excise, :with_excise_measure_components),
        ]
      end
    end

    trait :with_uk_complex_measure_units do
      with_excise_measures

      source { 'uk' }

      applicable_measure_units do
        {
          'DTN' => { # Duplicated in xi simple measurement units
            'measurement_unit_code' => 'DTN',
            'measurement_unit_qualifier_code' => nil,
            'abbreviation' => '100 kg',
            'unit_question' => 'What is the weight of the goods you will be importing?',
            'unit_hint' => 'Enter the value in kilogrammes',
            'unit' => 'kilogrammes',
            'multiplier' => '0.01',
            'coerced_measurement_unit_code' => 'KGM',
            'original_unit' => 'x 100 kg',
          },
          'RET' => { # Excise measurement unit code
            'measurement_unit_code' => 'RET',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => 'GBP',
            'unit_question' => 'What is the retail price of the goods you will be importing?',
            'unit_hint' => 'Enter the value in pounds',
            'unit' => '£',
          },
          'MIL' => { # Excise measurement unit code
            'measurement_unit_code' => 'MIL',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => '1,000 p/st',
            'unit_question' => 'How many items will you be importing?',
            'unit_hint' => 'Enter the value in thousands of items',
            'unit' => 'x 1,000 items',
          },
          'FC1X' => { # Excluded measurment unit code
            'measurement_unit_code' => 'FC1',
            'measurement_unit_qualifier_code' => 'X',
            'abbreviation' => 'Factor',
            'unit_question' => 'Please enter unit: Factor',
            'unit_hint' => 'Please correctly enter unit: Factor',
            'unit' => nil,
          },
          'ASV' => {
            'measurement_unit_code' => 'ASV',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => '% vol',
            'unit_question' => 'What is the alcohol percentage (%) of the goods you are importing?',
            'unit_hint' => 'Enter the alcohol by volume (ABV) percentage',
            'unit' => 'percent',
          },
          'DTNR' => { # Deduped measurement unit code
            'measurement_unit_code' => 'DTN',
            'measurement_unit_qualifier_code' => 'R',
            'abbreviation' => '100 kg std qual',
            'unit_question' => 'What is the weight net of the standard quality of the goods you will be importing?',
            'unit_hint' => 'Enter the value in kilogrammes',
            'unit' => 'kilogrammes',
            'multiplier' => '0.01',
            'coerced_measurement_unit_code' => 'KGM',
          },
          'KGM' => { # Deduped measurement unit code without coercian
            'measurement_unit_code' => 'KGM',
            'measurement_unit_qualifier_code' => nil,
            'abbreviation' => 'kg',
            'unit_question' => 'What is the weight of the goods that you will be importing?',
            'unit_hint' => 'Enter the value in kilograms',
            'unit' => 'kilograms',
            'multiplier' => nil,
            'coerced_measurement_unit_code' => nil,
          },
        }
      end
    end

    trait :with_xi_simple_measure_units do
      source { 'xi' }

      applicable_measure_units do
        {
          'DTN' => {
            'measurement_unit_code' => 'DTN',
            'measurement_unit_qualifier_code' => nil,
            'abbreviation' => '100 kg',
            'unit_question' => 'What is the weight of the goods you will be importing?',
            'unit_hint' => 'Enter the value in kilogrammes',
            'unit' => 'kilogrammes',
            'multiplier' => '0.01',
            'coerced_measurement_unit_code' => 'KGM',
          },
        }
      end
    end

    trait :with_spq_measurement_units do
      applicable_measure_units do
        {
          'HLT' => {
            'measurement_unit_code' => 'HLT',
            'measurement_unit_qualifier_code' => nil,
            'abbreviation' => 'hl',
            'expansion' => '100 litre (hl)',
            'unit_question' => 'What is the volume of the goods that you will be importing?',
            'unit_hint' => 'Enter the value in litres',
            'unit' => 'litres',
            'multiplier' => '0.01',
            'coerced_measurement_unit_code' => 'LTR',
            'original_unit' => 'x 100 litres',
            'measurement_unit_type' => 'volume',
          },
          'LPA' => {
            'measurement_unit_code' => 'LPA',
            'measurement_unit_qualifier_code' => nil,
            'abbreviation' => 'l alc. 100%',
            'expansion' => 'litre of pure (100%) alcohol (l alc. 100%)',
            'unit_question' => 'What is the volume of pure alcohol in the goods you will be importing?',
            'unit_hint' => 'Enter the value in litres',
            'unit' => 'litres',
            'multiplier' => nil,
            'coerced_measurement_unit_code' => nil,
            'original_unit' => nil,
            'measurement_unit_type' => 'volume',
          },
          'ASV' => {
            'measurement_unit_code' => 'ASV',
            'measurement_unit_qualifier_code' => nil,
            'abbreviation' => '% vol',
            'expansion' => 'percentage ABV (% vol)',
            'unit_question' => 'What is the alcohol percentage (%) of the goods you are importing?',
            'unit_hint' => 'Enter the alcohol by volume (ABV) percentage',
            'unit' => 'percent',
            'multiplier' => nil,
            'coerced_measurement_unit_code' => nil,
            'original_unit' => nil,
            'measurement_unit_type' => 'percentage_abv',
          },
          'SPR' => {
            'measurement_unit_code' => 'SPR',
            'measurement_unit_qualifier_code' => nil,
            'abbreviation' => 'SPR discount',
            'expansion' => 'SPR discount (£)',
            'unit_question' => 'What discount are you entitled to as a result of Small Producer Relief?',
            'unit_hint' => 'Enter the SPR discount against the full rate, not the chargeable SPR rate. For example, if the full rate, before application of SPR is £10.00 / litre of pure alcohol, and you are entitled to pay £7.00, enter 3.00 as your SPR discount.',
            'unit' => 'SPR discount (£)',
            'multiplier' => nil,
            'coerced_measurement_unit_code' => nil,
            'original_unit' => nil,
            'measurement_unit_type' => 'other',
          },
        }
      end
    end

    trait :with_none_additional_code_measures do
      applicable_additional_codes do
        {
          '103' => {
            'measure_type_description' => 'Foo',
            'heading' => {
              'overlay' => 'Bar',
              'hint' => 'Baz',
            },
            'additional_codes' => [
              {
                'code' => 'B107',
                'overlay' => 'BIOX Corporation, Oakville, Ontario, Canada<br>',
                'hint' => '',
                'measure_sid' => 20_041_389,
              },
              {
                'code' => 'none',
                'overlay' => 'Pick the none option',
                'hint' => '',
                'measure_sid' => 20_041_402,
              },
            ],
          },
        }
      end

      import_measures do
        [
          attributes_for(
            :duty_calculator_measure,
            :third_country_tariff,
            id: 20_041_389,
            additional_code: attributes_for(:duty_calculator_additional_code, code: 'B107'),
          ),
          attributes_for(
            :duty_calculator_measure,
            :third_country_tariff,
            id: 20_041_402,
            additional_code: nil,
          ),
          attributes_for(
            :duty_calculator_measure,
            :excise,
            additional_code: attributes_for(:duty_calculator_additional_code, code: 'X419'),
            id: 20_041_452,
          ),
          attributes_for(
            :duty_calculator_measure,
            :autonomous,
            id: 20_041_462,
          ),
        ]
      end
    end

    trait :with_all_variations_of_measurement_unit do
      applicable_measure_units do
        {
          'ASV' => {
            'measurement_unit_code' => 'ASV',
            'measurement_unit_qualifier_code' => nil,
            'unit_hint' => 'Enter the alcohol by volume (ABV) percentage',
            'measurement_unit_type' => 'percentage_abv',
          },
          'BRX' => {
            'measurement_unit_code' => 'BRX',
            'measurement_unit_qualifier_code' => nil,
            'unit_hint' => 'If you do not know the percentage sucrose content (Brix value), check the footnotes for the commodity code to identify how to calculate it.',
            'measurement_unit_type' => 'percentage',
          },
          'CEN' => {
            'measurement_unit_code' => 'CEN',
            'measurement_unit_qualifier_code' => nil,
            'unit_hint' => 'Enter the number of items',
            'measurement_unit_type' => 'number',
          },
          'HLT' => {
            'measurement_unit_code' => 'HLT',
            'measurement_unit_qualifier_code' => nil,
            'unit_hint' => 'Enter the value in litres',
            'measurement_unit_type' => 'volume',
          },
          'KGM' => {
            'measurement_unit_code' => 'KGM',
            'measurement_unit_qualifier_code' => nil,
            'unit_hint' => 'Enter the value in kilograms',
            'measurement_unit_type' => 'weight',
          },
          'SPR' => {
            'measurement_unit_code' => 'SPR',
            'measurement_unit_qualifier_code' => nil,
            'unit_hint' => 'Enter the SPR discount against the full rate, not the chargeable SPR rate. For example, if the full rate, before application of SPR is £10.00 / litre of pure alcohol, and you are entitled to pay £7.00, enter 3.00 as your SPR discount.',
            'measurement_unit_type' => 'discount',
          },
        }
      end
    end
  end
end
