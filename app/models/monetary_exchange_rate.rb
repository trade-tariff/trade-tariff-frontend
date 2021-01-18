require 'api_entity'

class MonetaryExchangeRate
  include ApiEntity

  collection_path '/monetary_exchange_rates'

  attr_accessor :child_monetary_unit_code,
                :exchange_rate,
                :operation_date,
                :validity_start_date

  def validity_start_date
    DateTime.parse(@validity_start_date)
  end

  def operation_date
    Date.parse(@operation_date)
  end

  def inverse_rate
    (1 / exchange_rate.to_f).to_d.truncate(9)
  end
end
