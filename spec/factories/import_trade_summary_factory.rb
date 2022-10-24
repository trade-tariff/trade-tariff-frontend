FactoryBot.define do
  factory :import_trade_summary do
    basic_third_country_duty { '<span>2.00</span>' }
    preferential_tariff_duty { nil }
    preferential_quota_duty  { nil }

    trait :with_tariff_duty do
      preferential_tariff_duty { '1.00 %' }
    end

    trait :with_quota_duty do
      preferential_quota_duty { '1.00 %' }
    end
  end
end
