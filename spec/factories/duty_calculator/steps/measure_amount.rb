FactoryBot.define do
  factory :duty_calculator_measure_amount, class: 'DutyCalculator::Steps::MeasureAmount', parent: :duty_calculator_step do
    transient do
      possible_attributes { { measure_amount: 'measure_amount', applicable_measure_units: 'applicable_measure_units' } }
      measure_amount { {} }
      applicable_measure_units do
        {
          'HLT' => {
            'measurement_unit_code' => 'HLT',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => 'hl',
            'unit_question' => 'What is the volume of the goods that you will be importing?',
            'unit_hint' => 'Enter the value in hectolitres (100 litres)',
            'unit' => 'x 100 litres',
            'measure_sids' => [
              20_002_280,
            ],
          },
          'DTN' => {
            'measurement_unit_code' => 'DTN',
            'measurement_unit_qualifier_code' => '',
            'abbreviation' => '100 kg',
            'unit_question' => 'What is the weight of the goods you will be importing?',
            'unit_hint' => 'Enter the value in decitonnes (100kg)',
            'unit' => 'x 100 kg',
            'measure_sids' => [
              20_005_920,
              20_056_507,
              20_073_335,
              20_076_779,
              20_090_066,
              20_105_690,
              20_078_066,
              20_102_998,
              20_108_866,
              20_085_014,
            ],
          },
        }
      end
    end
  end
end
