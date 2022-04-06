require 'api_entity'

class MeasureCondition
  include ApiEntity

  attr_accessor :condition_code,
                :condition,
                :document_code,
                :action,
                :duty_expression,
                :certificate_description,
                :guidance_cds,
                :guidance_chief

  attr_writer :requirement

  def requirement
    @requirement&.html_safe
  end

  def has_guidance?
    guidance_cds.present? || guidance_chief.present?
  end
end
