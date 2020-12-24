require 'api_entity'

class Commodity < GoodsNomenclature
  include Changeable
  include Declarable

  collection_path "/commodities"

  attr_accessor :parent_sid, :prev, :next

  has_one :heading
  # vat_measure is used for commodities under the heading only
  has_many :overview_measures, class_name: 'Measure', wrapper: MeasureCollection
  has_many :ancestors, class_name: 'Commodity'

  delegate :goods_nomenclature_item_id, :display_short_code, to: :heading, prefix: true
  alias :short_code :goods_nomenclature_item_id

  def substring=(substring)
    @substring ||= substring.to_i
  end

  def leaf?
    children.none?
  end

  def has_children?
    not(leaf?)
  end

  def display_short_code
    code[4..-1]
  end

  def display_export_code
    code[0..-3]
  end

  def chapter_code
    code[0..1]
  end

  def heading_code
    code[2..3]
  end

  # There are no consigned declarable headings
  def consigned?
    consigned
  end

  def to_param
    code
  end

  def to_s
    formatted_description || description
  end

  def root
    parent_sid.blank?
  end

  def children
    if casted_by.present?
      casted_by.commodities.select { |c| c.parent_sid == goods_nomenclature_sid }
    else
      []
    end
  end

  def last_child?
    if casted_by.present?
      goods_nomenclature_sid == casted_by.commodities.select { |c| c.parent_sid == parent_sid }.last.goods_nomenclature_sid
    else
      false
    end
  end

  def aria_label
    "Commodity code #{code}, " + description
  end
end
