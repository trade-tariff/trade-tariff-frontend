require 'api_entity'

class ProductSpecificRule
  include ApiEntity

  collection_path '/product_specific_rules'

  attr_accessor :heading, :description, :rule

  class << self
    def all(heading_code, country_code, opts = {})
      return mocked_response unless Rails.env.test?

      super opts.merge(
        heading_code: heading_code,
        country_code: country_code,
      )
    end

  private

    def mocked_response
      (1..6).map do |i|
        new \
          heading: "Chapter #{i}",
          description: 'Beverages',
          rule: <<~RULE
            Production from non originating materials, of any heading, provided
            that:

            * all materials from Chapter 4 are wholly owned
            * the total weight of non-originating materials does not exceed 20%
              of the weight of the product
          RULE
      end
    end
  end
end
