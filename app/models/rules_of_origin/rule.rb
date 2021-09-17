require 'api_entity'

class RulesOfOrigin::Rule
  include ApiEntity

  attr_accessor :id_rule, :heading, :description, :rule
end
