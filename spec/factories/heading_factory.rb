FactoryBot.define do
  factory :heading do
    transient do
      commodity_count { nil }
    end

    chapter { attributes_for(:chapter) }
    description { Forgery(:basic).text }
    formatted_description { Forgery(:basic).text }
    goods_nomenclature_item_id { '0101000000' }

    commodities { attributes_for_list :commodity, commodity_count || 0 }
    import_measures { [] }
    export_measures { [] }

    trait :with_commodity_tree do
      commodities do
        attributes_for_list(:commodity, commodity_count || 2) do |c, i|
          c[:parent_sid] = (i > 0 ? c[:goods_nomenclature_sid] - 1 : nil)
        end
      end
    end
  end
end
