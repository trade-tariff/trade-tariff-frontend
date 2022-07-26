require 'api_entity'

class RulesOfOrigin::V2Rule
  include ApiEntity

  WHOLLY_OBTAINED_CLASS = 'WO'.freeze

  attr_accessor :rule, :operator
  attr_writer :rule_class

  def rule_class
    @rule_class ||= []
  end

  def wholly_obtained_class?
    rule_class.include?(WHOLLY_OBTAINED_CLASS)
  end
end
