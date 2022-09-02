require 'api_entity'

class ImportTradeSummary
  include ApiEntity

  collection_path '/import_trade_summary'

  attr_accessor :basic_third_country_duty,
                :preferential_tariff_duty,
                :preferential_quota_duty

end
