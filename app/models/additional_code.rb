require 'api_entity'

class AdditionalCode
  include ApiEntity

  collection_path '/additional_codes'

  has_many :measures

  attr_accessor :additional_code_type_id, :additional_code, :code, :description, :formatted_description

  delegate :present?, to: :code, allow_nil: true

  def id
    @id ||= "#{casted_by.destination}-#{casted_by.id}-additional-code-#{code}"
  end

  def all_goods_nomenclatures
    @all_goods_nomenclatures ||= measures
      .map(&:goods_nomenclature)
      .uniq(&:goods_nomenclature_item_id)
      .sort_by(&:goods_nomenclature_item_id)
  end
end
