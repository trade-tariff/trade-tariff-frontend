require 'api_entity'

class RulesOfOrigin::Proof
  include ApiEntity

  attr_accessor :summary, :content
end
