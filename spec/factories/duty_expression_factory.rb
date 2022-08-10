FactoryBot.define do
  factory :duty_expression do
    base { '80.50 EUR / Hectokilogram' }
    formatted_base { "80.50 EUR / <abbr title='Hectokilogram'>Hectokilogram</abbr>" }

    trait :supplementary do
      description { 'Number of items' }
    end

    trait :vat do
      base { '20.0%' }
      formatted_base { '20.0%' }
      description { 'VAT' }
    end

    trait :vat_standard do
      vat
    end

    trait :vat_zero do
      base { '0.0%' }
      formatted_base { '0.0%' }
      description { 'VAT' }
    end

    trait :vat_reduced do
      base { '5.0%' }
      formatted_base { '5.0%' }
      description { 'VAT' }
    end
  end
end
