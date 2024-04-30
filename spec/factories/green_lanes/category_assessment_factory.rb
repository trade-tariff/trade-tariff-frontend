FactoryBot.define do
  factory :category_assessment, class: 'GreenLanes::CategoryAssessment' do
    transient do
      geographical_area_id { 'FR' }
      category { 2 }
    end

    theme        { attributes_for :green_lanes_theme, category: }
    measure_type { attributes_for :measure_type }
    regulation   { attributes_for :legal_act }

    geographical_area do
      attributes_for(:geographical_area, id: geographical_area_id)
    end

    trait :with_exemptions do
      exemptions do
        [
          attributes_for(:certificate),
          attributes_for(:additional_code),
        ]
      end
    end
  end
end
