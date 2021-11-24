class AdditionalCode
  include ApiEntity

  collection_path '/additional_codes'

  attr_accessor :additional_code_type_id, :additional_code, :code, :description, :formatted_description

  has_many :measures

  def id
    @id ||= "#{casted_by.destination}-#{casted_by.id}-additional-code-#{code}"
  end

  def present?
    code.present?
  end

  def to_s
    code
  end
end
