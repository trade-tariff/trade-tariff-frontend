require 'api_entity'

class MeasureCondition
  include ApiEntity

  attr_accessor :condition_code,
                :condition_measurement_unit_code,
                :condition_monetary_unit_code,
                :condition,
                :document_code,
                :action,
                :duty_expression,
                :certificate_description,
                :guidance_cds,
                :guidance_chief,
                :threshold_unit_type,
                :requirement_operator

  attr_writer :requirement, :measure_condition_class

  def requirement
    @requirement&.html_safe
  end

  def measure_condition_class
    ActiveSupport::StringInquirer.new(@measure_condition_class.to_s)
  end

  def has_guidance?
    guidance_cds.present? || guidance_chief.present?
  end
end
