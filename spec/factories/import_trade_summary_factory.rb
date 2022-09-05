FactoryBot.define do
  factory :import_trade_summary do
    basic_third_country_duty { '<span>2.00</span>' }
    preferential_tariff_duty { nil }
    preferential_quota_duty  { nil }
  end
end
