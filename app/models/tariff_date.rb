require 'active_model'

class TariffDate < SimpleDelegator
  DATE_KEYS = %w[year month day].freeze

  class << self
    def build(as_of, attributes)
      date = if as_of.present?
               handle_as_of(as_of)
             else
               handle_date_params(attributes)
             end

      new(date)
    end

    private

    def handle_as_of(as_of)
      Date.parse(as_of.to_s)
    rescue ArgumentError
      TariffUpdate.latest_applied_import_date
    end

    def handle_date_params(attributes)
      if valid_date_param?(attributes)
        Date.parse(attributes.slice(*DATE_KEYS).values.join('-'))
      else
        Time.zone.today
      end
    end

    def valid_date_param?(date_param)
      date_param.present? && date_param.is_a?(Hash) &&
        DATE_KEYS.all? { |k| k.in?(date_param.keys) }
    end
  end

  def persisted?
    false
  end

  def to_param
    to_formatted_s(:full)
  end

  def to_s(format = :date)
    to_formatted_s(format)
  end
end
