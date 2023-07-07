require 'api_entity'

class ExchangeRates::PeriodList
  include ApiEntity

  attr_accessor :year

  has_many :exchange_rate_years, class_name: 'ExchangeRates::Year'
  has_many :exchange_rate_periods, class_name: 'ExchangeRates::Period'

  def self.find(year, opts = {})
    opts[:year] = year
    super(nil, opts)
  end
end
