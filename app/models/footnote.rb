require 'api_entity'

class Footnote
  include ApiEntity
  include HasGoodsNomenclature

  collection_path '/footnotes'

  attr_accessor :code, :footnote_type_id, :footnote_id, :description, :formatted_description, :extra_large_measures

  has_many :measures
  has_many :goods_nomenclatures

  def base_goods_nomenclatures
    measures
      .map(&:goods_nomenclature)
      .concat(goods_nomenclatures)
  end
end
