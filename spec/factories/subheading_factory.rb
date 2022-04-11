FactoryBot.define do
  factory :subheading do
    section { attributes_for(:section) }
    chapter { attributes_for(:chapter) }
    commodities { [] }

    goods_nomenclature_item_id { '0101100000' }
    producline_suffix { '10' }
    goods_nomenclature_sid { 131_312 }
    number_indents { 3 }
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
