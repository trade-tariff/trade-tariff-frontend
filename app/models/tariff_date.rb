class TariffDate < SimpleDelegator
  DATE_KEYS = %w[year month day].freeze

  class << self
    def build(date_attributes)
      date = if complete_date_attributes?(date_attributes)
               raise Date::Error unless valid_date_attributes?(date_attributes)

               Date.new(*date_attributes.slice(*DATE_KEYS).values.map(&:to_i))
             else
               Time.zone.today
             end

      new(date)
    end

    private

    def complete_date_attributes?(date_param)
      date_param.present? && date_param.is_a?(Hash) &&
        DATE_KEYS.all? { |key| date_param[key].present? }
    end

    def valid_date_attributes?(date_param)
      DATE_KEYS.all? { |key| numeric_date_attribute?(date_param[key]) }
    end

    def numeric_date_attribute?(value)
      value.to_s.match?(/\A\d+\z/)
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
