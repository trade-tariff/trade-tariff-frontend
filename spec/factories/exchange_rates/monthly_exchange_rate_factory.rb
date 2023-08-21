FactoryBot.define do
  factory :monthly_exchange_rate, class: 'ExchangeRates::MonthlyExchangeRate' do
    year { 2023 }
    month { 6 }

    exchange_rate_files { attributes_for_list :exchange_rate_file, 1 }

    exchange_rates { attributes_for_list :exchange_rate, 1 }
  end
end
