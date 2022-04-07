FactoryBot.define do
  factory :duty_expression do
    base { '80.50 EUR / Hectokilogram' }
    formatted_base { "80.50 EUR / <abbr title='Hectokilogram'>Hectokilogram</abbr>" }

    trait :supplementary do
      description { 'Number of items' }
    end
  end
end
