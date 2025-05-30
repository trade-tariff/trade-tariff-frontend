FactoryBot.define do
  factory :duty_calculator_excise, class: 'DutyCalculator::Steps::Excise', parent: :duty_calculator_step do
    transient { possible_attributes { { measure_type_id: 'measure_type_id', additional_code: 'additional_code' } } }

    measure_type_id { '306' }
    additional_code { '444' }
  end
end
