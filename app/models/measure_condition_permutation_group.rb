require 'api_entity'

class MeasureConditionPermutationGroup
  include ApiEntity

  attr_accessor :condition_code

  has_many :permutations, class_name: 'MeasureConditionPermutation'
end
