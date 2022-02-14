require 'api_entity'

class MeasureType
  include ApiEntity

  SUPPLEMENTARY_MEASURE_TYPES = %w[109 110 111].freeze
  SUPPLEMENTARY_IMPORT_ONLY_MEASURE_TYPES = %w[110].freeze

  attr_accessor :id
  attr_writer :description

  def supplementary?
    id.in?(SUPPLEMENTARY_MEASURE_TYPES)
  end

  def description
    translated_description || attributes['description']
  end

  def supplementary_unit_import_only?
    id.in?(SUPPLEMENTARY_IMPORT_ONLY_MEASURE_TYPES)
  end

  private

  def translated_description
    I18n.t("measure_type_descriptions.#{geographical_area_id}.#{id}", default: nil)
  end

  def geographical_area_id
    casted_by.geographical_area.id
  end
end
