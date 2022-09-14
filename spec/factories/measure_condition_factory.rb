FactoryBot.define do
  factory :measure_condition do
    sequence(:resource_id)
    condition_code { Forgery(:basic).text(exactly: 1) }
    condition { Forgery(:basic).text }
    document_code { Forgery(:basic).text(exactly: 4) }
    requirement { Forgery(:basic).text }
    action { Forgery(:basic).text }
    duty_expression { Forgery(:basic).text }
    measure_condition_class { document_code.presence && 'document' }

    trait :universal_waiver do
      document_code { '999L' }
    end

    trait :with_guidance do
      guidance_cds { 'Guidance CDS' }
      guidance_chief { 'Guidance CHIEF' }
    end

    trait :threshold do
      measure_condition_class { 'threshold' }
    end

    trait :weight do
      threshold
      condition_measurement_unit_code { 'KGM' }
      threshold_unit_type { 'weight' }
    end

    trait :volume do
      threshold
      condition_measurement_unit_code { 'LTR' }
      threshold_unit_type { 'volume' }
    end

    trait :price do
      threshold
      condition_monetary_unit_code { 'EUR' }
      threshold_unit_type { 'price' }
    end

    trait :eps do
      weight
      price
      condition_code { 'V' }
      threshold_unit_type { 'eps' }
    end
  end
end
