class GoodsNomenclature
  include ApiEntity
  include Classifiable

  CHAPTER_SUFFIX = '00000000'.freeze
  HEADING_SUFFIX = '000000'.freeze

  attr_accessor :goods_nomenclature_item_id,
                :formatted_description,
                :description,
                :description_indexed,
                :self_text,
                :classification_description,
                :full_description,
                :heading_description,
                :producline_suffix,
                :search_references,
                :heading_id,
                :chapter_id,
                :description_plain,
                :declarable,
                :score,
                :confidence

  has_many :ancestors, polymorphic: true

  def self.is_heading_id?(goods_nomenclature_item_id)
    goods_nomenclature_item_id.ends_with?(HEADING_SUFFIX) && !goods_nomenclature_item_id.ends_with?(CHAPTER_SUFFIX)
  end

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
    goods_nomenclature_item_id.ends_with?(CHAPTER_SUFFIX)
  end

  def heading?
    self.class.is_heading_id?(goods_nomenclature_item_id)
  end

  def commodity?
    !goods_nomenclature_item_id.ends_with?(HEADING_SUFFIX)
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

  def formatted_self_text
    format_description(self_text)
  end

  def formatted_classification_description
    format_description(classification_description)
  end

  def rules_of_origin(*args, **kwargs)
    return nil unless declarable?

    @rules_of_origin ||= RulesOfOrigin::Scheme.for_heading_and_country(code, *args, **kwargs)
  end

  def rules_of_origin_rules(...)
    rules_of_origin(...).flat_map(&:rules)
  end

  private

  def format_description(text)
    GoodsNomenclature::DescriptionFormatter.new(text).to_html
  end
end
