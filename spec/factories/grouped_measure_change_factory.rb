FactoryBot.define do
  factory :grouped_measure_change, class: 'TariffChanges::GroupedMeasureChange' do
    resource_id { 'import_UK__default' }
    trade_direction { 'import' }
    count { 1 }

    # Use attributes hash for API entities
    geographical_area { { 'long_description' => 'Default Country' } }
    excluded_countries { [] }

    trait :export do
      trade_direction { 'export' }
    end

    trait :import do
      trade_direction { 'import' }
    end

    trait :with_uk_area do
      geographical_area { { 'long_description' => 'United Kingdom' } }
    end

    trait :with_eu_area do
      geographical_area { { 'long_description' => 'European Union' } }
    end

    trait :with_australia_area do
      geographical_area { { 'long_description' => 'Australia' } }
    end
  end
end
