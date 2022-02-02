class Subheading < GoodsNomenclature
  include ApiEntity

  has_one :section
  has_one :chapter
  has_one :heading

  has_many :footnotes
  has_many :commodities

  collection_path '/subheadings'

  attr_accessor :goods_nomenclature_item_id,
                :producline_suffix,
                :goods_nomenclature_sid,
                :number_indents,
                :description,
                :formatted_description,
                :declarable

  def page_heading
    "Subheading #{code} - #{self}"
  end

  def code
    case goods_nomenclature_item_id
    when /^\d+0000$/ then harmonised_system_subheading_code
    when /^\d+00$/ then combined_nomenclature_subheading_code
    else taric_subheading_code
    end
  end

  def to_param
    "#{goods_nomenclature_item_id}-#{producline_suffix}"
  end

  def to_s
    formatted_description || description
  end

  private

  def harmonised_system_subheading_code
    goods_nomenclature_item_id.first(6)
  end

  def combined_nomenclature_subheading_code
    goods_nomenclature_item_id.first(8)
  end

  def taric_subheading_code
    goods_nomenclature_item_id.first(10)
  end
end
