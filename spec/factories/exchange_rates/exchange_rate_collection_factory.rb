FactoryBot.define do
  factory :exchange_rate_collection, class: 'ExchangeRateCollection' do
    year { 2023 }
    month { 6 }
    type { 'scheduled' }

    exchange_rate_files { attributes_for_list :exchange_rate_file, 1 }

    exchange_rates { attributes_for_list :exchange_rate, 1 }
  end
end
