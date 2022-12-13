FactoryBot.define do
  factory :quota_closed_and_transferred_event, class: 'QuotaClosedAndTransferredEvent' do
    id { '1-2012-01-01' }
    transferred_amount { Forgery(:basic).number }
    closing_date { Date.current.iso8601 }
    quota_definition_validity_start_date { Date.current.iso8601 }
    quota_definition_validity_end_date { Date.current.iso8601 }
    quota_definition_measurement_unit { 'Kilogram (kg)' }
    target_quota_definition_validity_start_date { Date.current.iso8601 }
    target_quota_definition_validity_end_date {}
    target_quota_definition_measurement_unit { 'Kilogram (kg)' }
  end
end
