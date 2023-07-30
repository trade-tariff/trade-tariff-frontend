require 'api_entity'

class ExchangeRates::ExchangeRate
  include ApiEntity

  attr_accessor :year,
                :month,
                :country,
                :country_code,
                :currency_description,
                :currency_code,
                :rate,
                :validity_start_date,
                :validity_end_date
end
