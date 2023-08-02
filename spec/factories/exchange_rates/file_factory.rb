FactoryBot.define do
  factory :exchange_rate_file, class: 'ExchangeRates::File' do
    file_path { '/exchange_rates/csv/exrates-monthly-0623.csv' }
    format { 'csv' }
    file_size { 123 }
    publication_date { Date.new(2023, 7, 25) }
  end
end
