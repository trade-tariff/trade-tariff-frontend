FactoryBot.define do
  factory :measure_condition_permutation do
    transient do
      condition_count { 1 }
    end

    measure_conditions do
      attributes_for_list :measure_condition, condition_count, :with_guidance
    end
  end
end
