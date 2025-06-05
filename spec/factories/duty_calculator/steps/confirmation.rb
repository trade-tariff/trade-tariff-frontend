FactoryBot.define do
  factory :duty_calculator_confirmation, class: 'DutyCalculator::Steps::Confirmation', parent: :duty_calculator_step do
    transient { possible_attributes { {} } }
  end
end
