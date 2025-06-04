FactoryBot.define do
  factory :duty_calculator_final_use, class: 'DutyCalculator::Steps::FinalUse', parent: :duty_calculator_step do
    transient do
      possible_attributes { { final_use: 'final_use' } }
    end

    final_use { '' }
  end
end
