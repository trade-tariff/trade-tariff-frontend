class TariffDate < SimpleDelegator
  DATE_KEYS = %w[year month day].freeze

  class << self
    def normalized_date_attributes(date_attributes)
      normalize_date_attributes(date_attributes).compact
    end

    def build(date_attributes)
      normalized_attributes = normalize_date_attributes(date_attributes)

      date = if complete_date_attributes?(normalized_attributes)
               raise Date::Error unless valid_date_attributes?(normalized_attributes)

               Date.new(*normalized_attributes.slice(*DATE_KEYS).values.map(&:to_i))
             else
               Time.zone.today
             end

      new(date)
    end

    private

    def normalize_date_attributes(date_attributes)
      return {} unless date_attributes.respond_to?(:to_h)

      attributes = if date_attributes.respond_to?(:to_unsafe_h)
                     date_attributes.to_unsafe_h
                   else
                     date_attributes.to_h
                   end

      lookup = lambda do |*keys|
        keys.filter_map { |key| attributes[key].presence }.first
      end

      {
        'year' => lookup.call(
          'year', :year, 'as_of(year)', :'as_of(year)', 'as_of(1i)', :'as_of(1i)'
        ),
        'month' => lookup.call(
          'month', :month, 'as_of(month)', :'as_of(month)', 'as_of(2i)', :'as_of(2i)'
        ),
        'day' => lookup.call(
          'day', :day, 'as_of(day)', :'as_of(day)', 'as_of(3i)', :'as_of(3i)'
        ),
      }
    end

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
