FactoryBot.define do
  factory :measure_condition_permutation do
    measure_conditions { attributes_for_list :measure_condition, 1 }
  end
end
