require 'api_entity'

class ExchangeRateCollection
  include ApiEntity

  set_singular_path '/exchange_rates/:id'

  attr_accessor :month, :year, :type

  enum :type, {
    monthly: %w[monthly],
    annual: %w[average spot],
    average: %w[average],
    spot: %w[spot],
  }

  has_many :exchange_rate_files, class_name: 'ExchangeRates::File'
  has_many :exchange_rates, class_name: 'ExchangeRates::ExchangeRate'

  def month_name
    Date::MONTHNAMES[month.to_i]
  end

  def month_and_year_name
    "#{month_name} #{year}"
  end

  def published_date
    exchange_rate_files.first&.publication_date&.to_date&.to_fs(:short)
  end
end
