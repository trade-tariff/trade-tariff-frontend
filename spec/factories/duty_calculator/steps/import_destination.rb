FactoryBot.define do
  factory :import_destination, class: 'DutyCalculator::Steps::ImportDestination', parent: :step do
    transient do
      possible_attributes { { import_destination: 'import_destination' } }
    end

    import_destination { '' }
  end
end
