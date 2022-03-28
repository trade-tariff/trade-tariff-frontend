require 'api_entity'

class Footnote
  include ApiEntity

  collection_path '/footnotes'

  attr_accessor :code, :footnote_type_id, :footnote_id, :description, :formatted_description, :extra_large_measures

  has_many :measures
  has_many :goods_nomenclatures

  def all_goods_nomenclatures
    @all_goods_nomenclatures ||= measures
      .map(&:goods_nomenclature)
      .concat(goods_nomenclatures)
      .compact
      .uniq(&:goods_nomenclature_item_id)
      .sort_by(&:goods_nomenclature_item_id)
  end
end
