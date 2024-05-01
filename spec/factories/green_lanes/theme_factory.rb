FactoryBot.define do
  factory :green_lanes_theme, class: 'GreenLanes::Theme' do
    category { 1 }
    sequence(:resource_id) { |n| "#{category}.#{n}" }

    description do
      <<~EODESCRIPTION
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
        tempor incididunt ut labore et dolore magnam aliquam quaerat voluptatem.
      EODESCRIPTION
    end

    trait :category2 do
      category { 2 }
    end
  end
end
