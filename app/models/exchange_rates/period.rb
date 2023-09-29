require 'api_entity'

class ExchangeRates::Period
  include ApiEntity

  attr_accessor :year, :month, :has_exchange_rates

  has_many :files, class_name: 'ExchangeRates::File'

  def csv_file
    files.first
  end
end
