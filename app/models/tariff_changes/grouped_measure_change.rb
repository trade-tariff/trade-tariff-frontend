module TariffChanges
  class GroupedMeasureChange
    include AuthenticatableApiEntity
    include HasExcludedCountries

    set_collection_path '/uk/user/grouped_measure_changes'
    set_singular_path '/uk/user/grouped_measure_changes/:id'

    attr_accessor :trade_direction, :count

    has_one :geographical_area
    has_many :excluded_countries, class_name: 'GeographicalArea'
    has_many :grouped_measure_commodity_changes, class_name: 'TariffChanges::GroupedMeasureCommodityChange'

    def self.all(token, params = {})
      if token.nil? && !Rails.env.development?
        return []
      end

      collection_data = collection(collection_path, params, headers(token))

      collection_data.sort do |a, b|
        result = b.trade_direction <=> a.trade_direction # descending
        if result.zero?
          result = a.geographical_area_description <=> b.geographical_area_description # ascending
        end
        result
      end
    rescue Faraday::UnauthorizedError
      []
    end

    def geographical_area_description
      description = geographical_area.long_description

      if excluded_country_list.present?
        description << " excluding #{excluded_country_list}"
      end

      description
    end

    def trade_direction_description
      if trade_direction == 'both'
        'Imports and exports'
      else
        "#{trade_direction.capitalize}s"
      end
    end
  end
end
