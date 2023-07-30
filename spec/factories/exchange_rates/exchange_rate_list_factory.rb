FactoryBot.define do
  factory :exchange_rates_list, class: 'ExchangeRates::RatesList' do
    year { 2023 }
    month { 6 }

    exchange_rate_years { attributes_for_list :exchange_rate_file, 1 }

    exchange_rate_periods { attributes_for_list :exchange_rate, 1 }
  end
end
