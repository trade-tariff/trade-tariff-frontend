module SearchResult
  class HeadingSerializer < SimpleDelegator
    include ActiveModel::Serializers::JSON
    def serializable_hash(_opts = {})
      {
        type: 'heading',
        goods_nomenclature_item_id: goods_nomenclature_item_id,
        producline_suffix: producline_suffix,
        number_indents: number_indents,
        validity_start_date: validity_start_date.to_s,
        validity_end_date: validity_end_date.to_s,
        description: description,
        declarable: declarable,
      }
    end
  end
end
