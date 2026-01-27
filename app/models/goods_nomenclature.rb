require 'api_entity'
require 'null_object'

class GoodsNomenclature
  include ApiEntity

  include Classifiable

  attr_accessor :goods_nomenclature_item_id,
                :formatted_description,
                :description,
                :description_indexed,
                :producline_suffix,
                :search_references,
                :heading_id,
                :chapter_id,
                :description_plain,
                :declarable,
                :score

  has_many :ancestors, polymorphic: true

  def validity_start_date=(validity_start_date)
    return if validity_start_date.blank?

    @attributes['validity_start_date'] = validity_start_date.to_date
  end

  def validity_start_date
    @attributes['validity_start_date'].presence || NullObject.new
  end

  def validity_end_date=(validity_end_date)
    return if validity_end_date.blank?

    @attributes['validity_end_date'] = validity_end_date.to_date
  end

  def validity_end_date
    @attributes['validity_end_date'].presence || NullObject.new
  end

  def chapter?
    goods_nomenclature_item_id.ends_with?('00000000')
  end

  def heading?
    self.class.is_heading_id?(goods_nomenclature_item_id)
  end

  def commodity?
    !goods_nomenclature_item_id.ends_with?('000000')
  end

  def declarable?
    false
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

  def rules_of_origin(*args, **kwargs)
    return nil unless declarable?

    @rules_of_origin ||= RulesOfOrigin::Scheme.for_heading_and_country(code, *args, **kwargs)
  end

  def rules_of_origin_rules(...)
    rules_of_origin(...).flat_map(&:rules)
  end

  def self.is_heading_id?(goods_nomenclature_item_id)
    goods_nomenclature_item_id.ends_with?('000000') && goods_nomenclature_item_id.slice(2, 2) != '00'
  end
end
