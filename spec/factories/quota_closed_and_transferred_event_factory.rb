FactoryBot.define do
  factory :quota_closed_and_transferred_event, class: 'QuotaClosedAndTransferredEvent' do
    quota_definition { attributes_for(:definition) }
    transferred_amount { Forgery(:basic).number }
    closing_date { Date.current.iso8601 }
    id { '1-2012-01-01' }
  end
end
