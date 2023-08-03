require 'api_entity'

class ExchangeRates::Period
  include ApiEntity

  attr_accessor :year, :month

  has_many :files, class_name: 'ExchangeRates::File'
end
