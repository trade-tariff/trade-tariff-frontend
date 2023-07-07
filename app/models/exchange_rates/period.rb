require 'api_entity'

class ExchangeRates::Period
  include ApiEntity

  attr_accessor :year, :month
end
