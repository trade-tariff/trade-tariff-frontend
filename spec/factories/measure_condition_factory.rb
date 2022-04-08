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
  end
end
