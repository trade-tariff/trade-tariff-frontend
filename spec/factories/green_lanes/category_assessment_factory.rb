FactoryBot.define do
  factory :category_assessment, class: 'GreenLanes::GoodsNomenclature' do
    transient do
      geographical_area_id { 'FR' }
    end

    category { '1' }
    theme { 'Sanction' }

    geographical_area do
      attributes_for(:geographical_area, id: geographical_area_id)
    end

    trait :random_category do
      category { %w[1 2 3].sample }
      theme { %w[Sanction Food Other].sample }
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
