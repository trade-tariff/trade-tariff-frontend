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
    @guidance_cds_html ||= begin
      text = guidance_cds.is_a?(Hash) ? guidance_cds['content'] || guidance_cds[:content] : guidance_cds
      return ''.html_safe if text.nil?

      Govspeak::Document.new(text, sanitize: true).to_html.html_safe
    end
  end
end
