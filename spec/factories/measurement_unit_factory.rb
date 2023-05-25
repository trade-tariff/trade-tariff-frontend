FactoryBot.define do
  factory :measurement_unit do
    description { Forgery(:basic).text }
    measurement_unit_code { Forgery(:basic).text(exactly: 3).upcase }

    trait :supplementary do
      description { 'Number of items' }
      measurement_unit_code { 'NAR' }
    end

    trait :hectokilogram do
      description { 'Hectokilogram' }
      measurement_unit_code { 'DTN' }
    end
  end
end
