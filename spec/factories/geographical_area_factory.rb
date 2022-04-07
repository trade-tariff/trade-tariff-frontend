FactoryBot.define do
  factory :geographical_area do
    id { Forgery(:basic).text(exactly: 2).upcase }
    description { Forgery(:basic).text }

    trait :specific_country do
      description { Forgery(:basic).text }
    end

    trait :erga_omnes do
      id { '1011' }
    end
  end
end
