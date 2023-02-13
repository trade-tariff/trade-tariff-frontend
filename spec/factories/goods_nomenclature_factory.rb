FactoryBot.define do
  factory :goods_nomenclature do
    resource_type { 'goods_nomenclature' }
    description { Forgery(:basic).text }
    goods_nomenclature_item_id { '0100000000' }
    validity_start_date { Time.zone.today.ago(3.years) }
    validity_end_date   { nil }
  end
end
