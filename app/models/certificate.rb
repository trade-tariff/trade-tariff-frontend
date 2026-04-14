require 'api_entity'

class Certificate
  include ApiEntity

  attr_accessor :certificate_type_code,
                :certificate_code,
                :description,
                :formatted_description,
                :guidance_cds

  has_many :goods_nomenclatures, polymorphic: true

  def code
    "#{certificate_type_code}#{certificate_code}"
  end

  def to_s
    code
  end

  def guidance_cds_html
    return ''.html_safe unless guidance_cds.present?

    @guidance_cds_html ||= Govspeak::Document.new(guidance_cds, sanitize: true).to_html.html_safe
  end
end
