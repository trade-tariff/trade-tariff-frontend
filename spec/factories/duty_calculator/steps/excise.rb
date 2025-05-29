FactoryBot.define do
  factory :excise, class: 'DutyCalculator::Steps::Excise', parent: :step do
    transient { possible_attributes { { measure_type_id: 'measure_type_id', additional_code: 'additional_code' } } }

    measure_type_id { '306' }
    additional_code { '444' }
  end
end
