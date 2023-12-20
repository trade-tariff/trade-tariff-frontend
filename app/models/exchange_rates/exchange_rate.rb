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

  def formatted_validity_start_date
    validity_start_date&.to_date&.to_fs(:short)
  end

  def formatted_validity_end_date
    return 'n/a' if validity_end_date.blank?

    validity_end_date&.to_date&.to_fs(:short)
  end
end
