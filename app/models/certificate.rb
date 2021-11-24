class Certificate
  include ApiEntity

  collection_path '/certificates'

  attr_accessor :certificate_type_code, :certificate_code, :description, :formatted_description

  has_many :measures

  def code
    "#{certificate_type_code}#{certificate_code}"
  end

  def present?
    code.present?
  end

  def to_s
    code
  end
end
