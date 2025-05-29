FactoryBot.define do
  factory :stopping, class: 'DutyCalculator::Steps::Stopping', parent: :step do
    transient do
      possible_attributes { {} }
    end
  end
end
