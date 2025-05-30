FactoryBot.define do
  factory :duty_calculator_definition, class: 'DutyCalculator::Api::Definition' do
    id { '20857' }
    initial_volume { '46544000.0' }
    validity_start_date { '2021-04-01T00:00:00.000Z' }
    validity_end_date { '2021-06-30T23:59:59.000Z' }
    status { 'Open' }
    description { nil }
    balance { '46543125.437' }
    measurement_unit { 'Kilogram (kg)' }
    monetary_unit { nil }
    measurement_unit_qualifier { nil }
    last_allocation_date { '2021-04-08T13:30:00.000Z' }
    suspension_period_start_date { nil }
    suspension_period_end_date { nil }
    blocking_period_start_date { nil }
    blocking_period_end_date { nil }
  end
end
