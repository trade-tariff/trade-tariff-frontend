FactoryBot.define do
  factory :final_use, class: 'DutyCalculator::Steps::FinalUse', parent: :step do
    transient do
      possible_attributes { { final_use: 'final_use' } }
    end

    final_use { '' }
  end
end
