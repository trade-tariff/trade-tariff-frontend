module SearchResult
  class CommoditySerializer < SimpleDelegator
    include ActiveModel::Serializers::JSON
    def serializable_hash(_opts = {})
      {
        declarable:,
        description:,
        goods_nomenclature_item_id:,
        number_indents:,
        producline_suffix:,
        type: 'commodity',
        validity_end_date: validity_end_date.to_s,
        validity_start_date: validity_start_date.to_s,
      }
    end
  end
end
