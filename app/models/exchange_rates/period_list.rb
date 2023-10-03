require 'api_entity'

class ExchangeRates::PeriodList
  AVERAGE_RATE = 'average'.freeze
  SCHEDULED_RATE = 'scheduled'.freeze
  SPOT_RATE = 'spot'.freeze

  include ApiEntity

  attr_accessor :year, :type

  has_many :exchange_rate_years, class_name: 'ExchangeRates::Year'
  has_many :exchange_rate_periods, class_name: 'ExchangeRates::Period'

  def publication_date
    raise Faraday::ResourceNotFound if exchange_rate_periods.empty?

    date_str = exchange_rate_periods.first.files.first&.publication_date
    date = Date.parse(date_str) if date_str
    date&.to_formatted_s(:long)
  end

  def type_label(capitalize: false)
    label = type == SCHEDULED_RATE ? 'monthly' : type

    capitalize ? label.capitalize : label
  end

  def monthly?
    type == SCHEDULED_RATE
  end

  def average?
    type == AVERAGE_RATE
  end

  def annual?
    type.in?(%w[SPOT_RATE AVERAGE_RATE])
  end

  def self.valid_rate_type?(type)
    [AVERAGE_RATE, SCHEDULED_RATE, SPOT_RATE].include?(type)
  end
end
