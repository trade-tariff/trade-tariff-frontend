module SearchResult
  class ChapterSerializer < SimpleDelegator
    include ActiveModel::Serializers::JSON
    def serializable_hash(_opts = {})
      {
        type: 'chapter',
        goods_nomenclature_item_id:,
        validity_start_date: validity_start_date.to_fs,
        validity_end_date: validity_end_date.to_fs,
        description:,
      }
    end
  end
end
