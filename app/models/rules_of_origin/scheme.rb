require 'api_entity'

class RulesOfOrigin::Scheme
  include ApiEntity

  collection_path '/rules_of_origin_schemes'

  attr_accessor :scheme_code, :title, :countries, :footnote, :fta_intro

  has_many :rules, class_name: 'RulesOfOrigin::Rule'

  class << self
    def all(heading_code, country_code, opts = {})
      super opts.merge(
        heading_code: heading_code.first(6),
        country_code: country_code,
      )
    end
  end
end
