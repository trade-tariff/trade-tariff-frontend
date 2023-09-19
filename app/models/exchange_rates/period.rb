require 'api_entity'

class ExchangeRates::Period
  include ApiEntity

  attr_accessor :year, :month

  has_many :files, class_name: 'ExchangeRates::File'

  def file_csv
    files.find { |f| f[:format] == 'csv' }
  end
end
