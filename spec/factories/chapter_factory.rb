FactoryBot.define do
  factory :chapter do
    section { attributes_for(:section) }
    description { Forgery(:basic).text }
    goods_nomenclature_item_id { '0100000000' }
    formatted_description { Forgery(:basic).text }
  end
end
