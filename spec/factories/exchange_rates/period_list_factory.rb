FactoryBot.define do
  factory :exchange_rate_period_list, class: 'ExchangeRates::PeriodList' do
    year { 2020 }

    exchange_rate_years { attributes_for_list :exchange_rate_year, 1 }

    exchange_rate_periods { attributes_for_list :exchange_rate_period, 1 }
  end
end
