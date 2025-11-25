FactoryBot.define do
  factory :commodity_change, class: 'TariffChanges::CommodityChange' do
    resource_id { 'commodity_endings' }
    description { 'Changes to end date' }
    count { 3 }
  end
end
