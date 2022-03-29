require 'api_entity'

class AdditionalCode
  include ApiEntity
  include HasGoodsNomenclature

  collection_path '/additional_codes'

  has_many :measures

  attr_accessor :additional_code_type_id, :additional_code, :code, :description, :formatted_description

  delegate :present?, to: :code, allow_nil: true

  def id
    @id ||= "#{casted_by.destination}-#{casted_by.id}-additional-code-#{code}"
  end
end
