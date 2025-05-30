FactoryBot.define do
  factory :duty_calculator_step_additional_code, class: 'DutyCalculator::Steps::AdditionalCode', parent: :duty_calculator_step do
    transient { possible_attributes { { measure_type_id: 'measure_type_id', additional_code_uk: 'additional_code_uk', additional_code_xi: 'additional_code_xi' } } }

    measure_type_id { '105' }
    additional_code_uk { '2300' }
    additional_code_xi { '2600' }
  end
end
