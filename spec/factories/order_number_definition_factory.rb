FactoryBot.define do
  factory :definition, class: 'OrderNumber::Definition' do
    quota_definition_sid { Forgery(:basic).number }
    initial_volume { '54000.0' }
    validity_start_date { '2021-01-01T00:00:00.000Z' }
    validity_end_date { '2021-12-31T00:00:00.000Z' }
    status { 'Open' }
    description { nil }
    balance { '54000.0' }
    measurement_unit { 'Kilogram (kg)' }
    monetary_unit { nil }
    measurement_unit_qualifier { nil }
    last_allocation_date { nil }
    suspension_period_start_date { nil }
    suspension_period_end_date { nil }
    blocking_period_start_date { nil }
    blocking_period_end_date { nil }
    order_number { attributes_for(:order_number) }
  end
end
