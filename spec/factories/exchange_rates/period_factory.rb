FactoryBot.define do
  factory :exchange_rate_period, class: 'ExchangeRates::Period' do
    sequence(:year) { |n| 2022 - n + 1 }
    month { 6 }
  end
end
