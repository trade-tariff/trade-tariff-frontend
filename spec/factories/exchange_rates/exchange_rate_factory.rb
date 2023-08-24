FactoryBot.define do
  factory :exchange_rate, class: 'ExchangeRates::ExchangeRate' do
    month { 6 }
    year { 2023 }
    country { 'Abu Dhabi' }
    country_code { 'DH' }
    currency_description { 'Dirham' }
    currency_code { 'AED' }
    rate { 4.5409 }
    validity_start_date { '2023-06-01' }
    validity_end_date { '2023-06-30' }
  end
end
