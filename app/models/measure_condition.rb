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
  attr_reader :measure_condition_class

  def requirement
    @requirement&.html_safe
  end

  def has_guidance?
    guidance_cds.present? || guidance_chief.present?
  end

  def measure_condition_class=(condition_class)
    @measure_condition_class =
      ActiveSupport::StringInquirer.new(condition_class.to_s)
  end
end
