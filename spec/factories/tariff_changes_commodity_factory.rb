FactoryBot.define do
  factory :tariff_changes_commodity, class: 'TariffChanges::Commodity' do
    resource_type { 'commodity' }
    resource_id { '29847' }
    classification_description { 'Cheddar > Other' }
    goods_nomenclature_item_id { '0406902190' }
    validity_end_date { nil }
    chapter { '04' }
    heading { 'Cheese and curd' }
  end
end
