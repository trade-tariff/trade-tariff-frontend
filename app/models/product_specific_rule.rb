require 'api_entity'

class ProductSpecificRule
  include ApiEntity

  collection_path '/product_specific_rules'

  attr_accessor :heading, :description, :rule

  class << self
    def all(heading_code, country_code, opts = {})
      super opts.merge(
        heading_code: heading_code,
        country_code: country_code,
      )
    end
  end
end
