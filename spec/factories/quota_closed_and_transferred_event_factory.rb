FactoryBot.define do
  factory :quota_closed_and_transferred_event, class: 'QuotaClosedAndTransferredEvent' do
    transferred_amount { '54000.0' }
    closing_date { '2021-12-31T00:00:00.000Z' }
    id { '1' }
  end
end
