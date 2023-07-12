require 'api_entity'

class ExchangeRates::Year
  include ApiEntity

  HIDDEN_YEAR = 2020

  attr_accessor :year
end
