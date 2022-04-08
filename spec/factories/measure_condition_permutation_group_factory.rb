FactoryBot.define do
  factory :measure_condition_permutation_group do
    transient do
      measure_conditions { nil }
      condition_count { 1 }
      permutation_count { 1 }
    end

    permutations do
      if measure_conditions
        attributes_for_list :measure_condition_permutation, 1,
                            measure_conditions: measure_conditions
      else
        attributes_for_list :measure_condition_permutation,
                            permutation_count,
                            condition_count: condition_count
      end
    end
  end
end
