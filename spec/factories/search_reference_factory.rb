FactoryBot.define do
  factory :search_reference do
    id { '1' }

    title { 'tomatoes' }

    referenced_id { '1234567890' }

    trait :with_subheading do
      referenced_class { 'Subheading' }
      productline_suffix { '12' }
    end
  end
end
