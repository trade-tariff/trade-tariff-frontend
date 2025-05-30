FactoryBot.define do
  factory :order_number do
    number { Forgery(:basic).number(exactly: 6).to_s }

    trait :with_definition do
      quota_definition { attributes_for(:quota_definition) }
    end

    trait :no_definition do
      quota_definition { nil }
    end

    trait :licenced do
      number { '054002' }
    end

    trait :non_licenced do
      number { '055002' }
    end
  end
end
