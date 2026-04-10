require 'api_entity'

class MeasureCondition
  OVERRIDDEN_ACTION_CODES = {
    '01' => 'Apply the duty',
  }.freeze

  include ApiEntity

  attr_accessor :condition_code,
                :condition_measurement_unit_code,
                :condition_monetary_unit_code,
                :condition,
                :document_code,
                :action,
                :action_code,
                :duty_expression,
                :certificate_description,
                :guidance_cds,
                :threshold_unit_type,
                :requirement_operator

  attr_writer :requirement, :measure_condition_class

  def requirement_text
    (certificate_description.presence || requirement.to_s).html_safe
  end

  def requirement
    @requirement&.html_safe
  end

  def measure_condition_class
    ActiveSupport::StringInquirer.new(@measure_condition_class.to_s)
  end

  def has_guidance?
    guidance_cds.present?
  end

  def guidance_cds_html
    @guidance_cds_html ||= begin
      text = guidance_cds.is_a?(Hash) ? guidance_cds['content'] || guidance_cds[:content] : guidance_cds
      return ''.html_safe if text.nil?

      Govspeak::Document.new(text, sanitize: true).to_html.html_safe
    end
  end

  def presented_action
    OVERRIDDEN_ACTION_CODES.fetch(action_code.to_s, action)
  end
end
