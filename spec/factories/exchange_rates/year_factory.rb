FactoryBot.define do
  factory :exchange_rate_year, class: 'ExchangeRates::Year' do
    sequence(:year) { |n| 2022 - n + 1 }
  end
end
