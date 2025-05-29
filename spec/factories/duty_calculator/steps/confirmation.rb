FactoryBot.define do
  factory :confirmation, class: 'DutyCalculator::Steps::Confirmation', parent: :step do
    transient { possible_attributes { {} } }
  end
end
