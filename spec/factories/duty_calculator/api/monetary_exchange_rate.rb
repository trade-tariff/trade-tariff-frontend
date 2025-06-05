FactoryBot.define do
  sequence(:monetary_exchange_rate_id)

  factory :duty_calculator_monetary_exchange_rate, class: 'DutyCalculator::Api::MonetaryExchangeRate' do
    id { generate(:monetary_exchange_rate_id) }
    child_monetary_unit_code { 'GBP' }
    exchange_rate { '0.7298' }
    operation_date { nil }
    validity_start_date { '2016-01-01T00:00:00.000Z' }
  end
end
