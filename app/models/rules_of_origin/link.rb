require 'api_entity'

class RulesOfOrigin::Link
  include ApiEntity

  attr_accessor :text, :url
end
