FactoryBot.define do
  factory :duty_calculator_planned_processing, class: 'DutyCalculator::Steps::PlannedProcessing', parent: :duty_calculator_step do
    transient do
      possible_attributes { { planned_processing: 'planned_processing' } }
    end

    planned_processing { '' }
  end
end
