FactoryBot.define do
  factory :search_reference do
    id { '1' }

    title { 'tomatoes' }

    referenced_id { '1234567890' }

    trait :with_chapter do
      referenced_id { '20' }
      referenced_class { 'Chapter' }
      productline_suffix { '80' }
    end

    trait :with_heading do
      referenced_id { '2001' }
      referenced_class { 'Heading' }
      productline_suffix { '80' }
    end

    trait :with_subheading do
      referenced_id { '8418690000-10' }
      referenced_class { 'Subheading' }
      productline_suffix { '10' }
    end

    trait :with_commodity do
      referenced_id { '8418690000' }
      referenced_class { 'Commodity' }
      productline_suffix { '80' }
    end
  end
end
