FactoryBot.define do
  factory :chemical_substance do
    resource_id { "#{cus}-#{goods_nomenclature_sid}" }
    cus { '0010020-9' }
    cas_rn { '102-28-3' }
    goods_nomenclature_sid { 101_368 }
    goods_nomenclature_item_id { '2924297099' }
    producline_suffix { '80' }
    name { "3'-aminoacetanilide" }
  end
end
