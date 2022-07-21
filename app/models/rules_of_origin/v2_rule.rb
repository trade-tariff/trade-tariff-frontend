require 'api_entity'

class RulesOfOrigin::V2Rule
  include ApiEntity

  attr_accessor :rule, :rule_class, :operator
end
