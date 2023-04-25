FactoryBot.define do
  factory :duty_expression do
    base { '80.50 EUR / Hectokilogram' }
    verbose_duty { '£7.80 / 100 kg, drained net weight (kg/net eda)' }
    formatted_base { '£7.80 / 100 kg, drained net weight (kg/net eda)' }

    trait :third_country do
      description { 'Percentage' }
      formatted_base { '2.00%' }
      base { '2.00%' }
    end

    trait :supplementary do
      description { 'Number of items' }
      formatted_base { 'p/st' }
      base { 'p/st' }
    end

    trait :vat do
      base { '20.0%' }
      description { 'VAT' }
      verbose_duty { '20.0%' }
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
