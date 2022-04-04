require 'api_entity'

class Certificate
  include ApiEntity
  include HasGoodsNomenclature

  collection_path '/certificates'

  attr_accessor :certificate_type_code,
                :certificate_code,
                :description,
                :formatted_description,
                :guidance_cds,
                :guidance_chief

  has_many :measures

  def code
    "#{certificate_type_code}#{certificate_code}"
  end

  def to_s
    code
  end
end
