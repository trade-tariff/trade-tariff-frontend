require 'api_entity'

class RulesOfOrigin::Proof
  include ApiEntity

  attr_accessor :summary, :url, :subtext
end
