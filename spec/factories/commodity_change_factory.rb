FactoryBot.define do
  factory :commodity_change, class: 'TariffChanges::CommodityChange' do
    resource_id { 'ending' }
    description { 'Changes to end date' }
    count { 3 }
  end
end
