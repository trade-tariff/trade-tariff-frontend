require 'api_entity'

class MeasurementUnit
  include ApiEntity

  attr_accessor :description, :measurement_unit_code
end
