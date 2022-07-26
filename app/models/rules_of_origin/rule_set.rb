require 'api_entity'

class RulesOfOrigin::RuleSet
  include ApiEntity

  attr_accessor :heading, :subdivision

  has_many :rules, class_name: 'RulesOfOrigin::V2Rule'
end
