FactoryBot.define do
  factory :subheading do
    transient do
      commodities_count { 0 }
    end

    section { attributes_for(:section) }

    chapter do
      attributes_for :chapter,
                     goods_nomenclature_item_id: "#{goods_nomenclature_item_id.first(2)}00000000"
    end

    heading do
      attributes_for :heading,
                     goods_nomenclature_item_id: "#{goods_nomenclature_item_id.first(4)}000000"
    end

    goods_nomenclature_item_id { '0101100000' }
    producline_suffix { '10' }
    goods_nomenclature_sid { 131_312 }
    number_indents { 3 }

    commodities { attributes_for_list :commodity, commodities_count }

    description { 'Horses' }
    formatted_description { '<strong>Horses</strong>' }
    declarable { false }

    trait :harmonised_system_code do
      goods_nomenclature_item_id { '0101100000' }
    end

    trait :combined_nomenclature_code do
      goods_nomenclature_item_id { '0101111000' }
    end

    trait :taric_code do
      goods_nomenclature_item_id { '0101121210' }
    end
  end
end
