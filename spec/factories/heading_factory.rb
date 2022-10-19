FactoryBot.define do
  factory :heading do
    transient do
      commodity_count { nil }
    end

    chapter { attributes_for(:chapter) }
    description { Forgery(:basic).text }
    formatted_description { Forgery(:basic).text }
    goods_nomenclature_item_id { '0101000000' }
    resource_type { 'heading' }

    commodities { attributes_for_list :commodity, commodity_count || 0 }
    import_measures { [] }
    export_measures { [] }
    ancestors { [] }

    trait :with_commodity_tree do
      commodities do
        attributes_for_list(:commodity, commodity_count || 2) do |commodity, index|
          commodity[:parent_sid] = if index.zero? # First commodity, so no parent
                                     nil
                                   else # point parent to the previous commodity
                                     commodity[:goods_nomenclature_sid] - 1
                                   end
        end
      end
    end

    trait :with_subheading_and_commodity do
      transient do
        producline_suffix {}
      end

      commodities do
        subheading = attributes_for(:commodity, producline_suffix:, number_indents: 2)
        commodity =  attributes_for(:commodity, producline_suffix:, parent_sid: subheading[:goods_nomenclature_sid], number_indents: 3)

        [subheading, commodity]
      end
    end
  end
end
