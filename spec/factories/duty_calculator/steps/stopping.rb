FactoryBot.define do
  factory :duty_calculator_stopping, class: 'DutyCalculator::Steps::Stopping', parent: :duty_calculator_step do
    transient do
      possible_attributes { {} }
    end
  end
end
