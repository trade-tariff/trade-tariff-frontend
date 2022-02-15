require 'active_model'

class TariffDate < SimpleDelegator
  DATE_KEYS = %w[year month day].freeze

  class << self
    def build(date_attributes)
      date = if valid_date_param?(date_attributes)
               Date.parse(date_attributes.slice(*DATE_KEYS).values.join('-'))
             else
               Time.zone.today
             end

      new(date)
    end

    # TODO: We should remove support for as_of as a query param when making html calls
    def build_legacy(as_of)
      date = begin
        Date.parse(as_of.to_s)
      rescue ArgumentError
        Time.zone.today
      end

      new(date)
    end

    private

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
