require 'api_entity'

class MeasurementUnitQualifier
  include ApiEntity

  attr_accessor :description, :formatted_description
end
