module HasGoodsNomenclature
  extend ActiveSupport::Concern

  def base_goods_nomenclatures
    measures.map(&:goods_nomenclature)
  end

  def all_goods_nomenclatures
    @all_goods_nomenclatures ||= base_goods_nomenclatures
      .compact
      .uniq(&:goods_nomenclature_item_id)
      .sort_by(&:goods_nomenclature_item_id)
  end
end
