require 'api_entity'

class MeasureConditionPermutation
  include ApiEntity

  has_many :measure_conditions
end
