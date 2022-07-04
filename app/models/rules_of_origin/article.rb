require 'api_entity'

class RulesOfOrigin::Article
  include ApiEntity

  attr_accessor :article, :content
end
