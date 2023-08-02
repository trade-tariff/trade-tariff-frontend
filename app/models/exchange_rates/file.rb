require 'api_entity'

class ExchangeRates::File
  include ApiEntity

  attr_accessor :file_path,
                :file_size,
                :publication_date,
                :format
end
