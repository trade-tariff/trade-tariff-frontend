require 'api_entity'

class ExchangeRates::File
  include ApiEntity

  attr_accessor :year,
                :month,
                :file_path,
                :file_size,
                :publication_date,
                :format

  def file_size_in_kb
    sprintf('%.1f', file_size.to_f / 1024)
  end
end
