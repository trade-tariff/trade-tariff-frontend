FactoryBot.define do
  factory :definition, class: 'OrderNumber::Definition' do
    transient do
      number { Forgery(:basic).number(exactly: 6).to_s }
    end

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
    order_number { attributes_for(:order_number, number:) }

    trait :historical do
      validity_start_date { 4.months.ago.iso8601 }
      validity_end_date { 1.month.ago.iso8601 }
    end

    trait :future do
      validity_start_date { 1.month.from_now.iso8601 }
      validity_end_date { 4.months.from_now.iso8601 }
    end

    trait :current do
      validity_start_date { 1.month.ago.iso8601 }
      validity_end_date { 2.months.from_now.iso8601 }
    end
  end
end
