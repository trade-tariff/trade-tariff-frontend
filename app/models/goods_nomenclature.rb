require 'api_entity'
require 'null_object'

class GoodsNomenclature
  include ApiEntity

  attr_accessor :goods_nomenclature_item_id,
                :formatted_description,
                :description

  def validity_start_date=(validity_start_date)
    @attributes['validity_start_date'] = Date.parse(validity_start_date.to_s) if validity_start_date.present?
  end

  def validity_start_date
    @attributes['validity_start_date'].presence || NullObject.new
  end

  def validity_end_date=(validity_end_date)
    @attributes['validity_end_date'] = Date.parse(validity_end_date.to_s) if validity_end_date.present?
  end

  def validity_end_date
    @attributes['validity_end_date'].presence || NullObject.new
  end

  def chapter?
    goods_nomenclature_item_id.ends_with?('00000000')
  end

  def heading?
    goods_nomenclature_item_id.ends_with?('000000') && goods_nomenclature_item_id.slice(2, 2) != '00'
  end

  def commodity?
    !goods_nomenclature_item_id.ends_with?('000000')
  end

  def type
    return 'chapter' if chapter?
    return 'heading' if heading?
    return 'commodity' if commodity?

    'goods_nomenclature'
  end

  def id
    goods_nomenclature_item_id
  end

  def code
    goods_nomenclature_item_id
  end
end
