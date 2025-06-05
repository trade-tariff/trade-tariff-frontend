FactoryBot.define do
  factory :duty_calculator_prefill, class: 'DutyCalculator::Steps::Prefill', parent: :duty_calculator_step do
    transient do
      possible_attributes { {} }
    end
  end
end
