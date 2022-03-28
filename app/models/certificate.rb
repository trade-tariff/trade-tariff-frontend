require 'api_entity'

class Certificate
  include ApiEntity

  collection_path '/certificates'

  attr_accessor :certificate_type_code, :certificate_code, :description, :formatted_description

  has_many :measures

  def code
    "#{certificate_type_code}#{certificate_code}"
  end

  def to_s
    code
  end

  def all_goods_nomenclatures
    @all_goods_nomenclatures ||= measures
      .map(&:goods_nomenclature)
      .compact
      .uniq(&:goods_nomenclature_item_id)
      .sort_by(&:goods_nomenclature_item_id)
  end
end
