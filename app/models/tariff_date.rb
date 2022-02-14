class TariffDate < SimpleDelegator
  DATE_KEYS = %w[year month day].freeze

  class << self
    def build(date_attributes)
      date = if valid_date_attributes?(date_attributes)
               Date.parse(date_attributes.slice(*DATE_KEYS).values.join('-'))
             else
               Time.zone.today
             end

      new(date)
    end

    private

    def valid_date_attributes?(date_param)
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

  alias_method :to_fs, :to_s
end
