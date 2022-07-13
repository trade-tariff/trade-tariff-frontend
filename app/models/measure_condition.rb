require 'api_entity'

class MeasureCondition
  include ApiEntity

  WEIGHT_UNITS = %w[DTN DAP DHS GFI GRM GRT KGM KMA RET TNE].freeze
  VOLUME_UNITS = %w[HLT KLT LPA LTR MIL MTQ].freeze
  CONDITION_CODE_V = 'V'.freeze

  attr_accessor :condition_code,
                :condition_measurement_unit_code,
                :condition_monetary_unit_code,
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

  def is_price_condition?
    condition_monetary_unit_code.present?
  end

  def is_weight_condition?
    WEIGHT_UNITS.include? condition_measurement_unit_code
  end

  def is_volume_condition?
    VOLUME_UNITS.include? condition_measurement_unit_code
  end

  def is_eps_condition_code_v?
    CONDITION_CODE_V == condition_code && is_price_condition? && is_weight_condition?
  end
end
