require 'api_entity'

class RulesOfOrigin::V2Rule
  include ApiEntity

  WHOLLY_OBTAINED_CLASS = 'WO'.freeze

  attr_accessor :rule, :operator
  attr_writer :rule_class, :footnotes

  def rule_class
    @rule_class ||= []
  end

  def footnotes
    @footnotes ||= []
  end

  def all_footnotes
    footnotes.join("\n\n").presence
  end

  def only_wholly_obtained_class?
    rule_class.one? && rule_class.include?(WHOLLY_OBTAINED_CLASS)
  end
end
