module DutyCalculator
  class CommodityContextService
    def initialize
      @cache = {}
    end

    def call(commodity_source, commodity_code, query = {})
      digest = Digest::SHA2.hexdigest(query.to_json)
      key = "commodity-#{commodity_code}-#{commodity_source}-#{digest}"
      @cache[key] ||= Api::Commodity.build(
        commodity_source,
        commodity_code,
        query,
      )
    end
  end
end
