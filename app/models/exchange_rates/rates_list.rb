require 'api_entity'

class ExchangeRates::RatesList
  include ApiEntity

  attr_accessor :month, :year, :publication_date

  has_many :exchange_rate_files, class_name: 'ExchangeRates::File'
  has_many :exchange_rates, class_name: 'ExchangeRates::ExchangeRate'
end
