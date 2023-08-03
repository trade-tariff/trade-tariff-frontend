FactoryBot.define do
  factory :exchange_rate_file, class: 'ExchangeRates::File' do
    file_path { '/exchange_rates/csv/exrates-monthly-0623.csv' }
    format { 'csv' }
    file_size { 2048 }
    publication_date { '2023-07-25' }
  end
end
