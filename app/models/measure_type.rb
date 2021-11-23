require 'api_entity'

class MeasureType
  include ApiEntity

  SUPPLEMENTARY_MEASURE_TYPES = %w[109 110 111].freeze
  SUPPLEMENTARY_IMPORT_ONLY_MEASURE_TYPES = %w[110].freeze

  attr_accessor :id, :description

  def supplementary?
    id.in?(SUPPLEMENTARY_MEASURE_TYPES)
  end

  def supplementary_unit_import_only?
    id.in?(SUPPLEMENTARY_IMPORT_ONLY_MEASURE_TYPES)
  end
end
