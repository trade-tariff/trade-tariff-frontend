class AdditionalCodeType
  include ApiEntity

  collection_path '/additional_code_types'

  attr_accessor :additional_code_type_id, :description
end
