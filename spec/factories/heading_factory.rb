FactoryBot.define do
  factory :heading do
    chapter { attributes_for(:chapter) }
    description { Forgery(:basic).text }
    formatted_description { Forgery(:basic).text }
    goods_nomenclature_item_id { '0101000000' }

    commodities { [] }
    import_measures { [] }
    export_measures { [] }
  end
end
