require 'api_entity'

class RulesOfOrigin::Rule
  include ApiEntity

  attr_accessor :id_rule, :heading, :description, :rule

  class << self
    def all(heading_code, country_code, opts = {})
      super opts.merge(
        heading_code: heading_code.first(6),
        country_code: country_code,
      )
    end
  end
end
