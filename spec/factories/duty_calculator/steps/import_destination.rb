FactoryBot.define do
  factory :duty_calculator_import_destination, class: 'DutyCalculator::Steps::ImportDestination', parent: :duty_calculator_step do
    transient do
      possible_attributes { { import_destination: 'import_destination' } }
    end

    import_destination { '' }
  end
end
