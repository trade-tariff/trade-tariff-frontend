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

    def self.find(id, token, opts = {})
      return nil if token.nil? && !Rails.env.development?

      path = singular_path.sub(':id', id)
      resp = api.get(path, opts, headers(token))
      record = new parse_jsonapi(resp)
      collection = record.grouped_measure_commodity_changes

      if resp.body.is_a?(Hash) && resp.body.dig('meta', 'pagination').present?
        collection = paginate_collection(collection, resp.body.dig('meta', 'pagination'))
      end

      record.instance_variable_set(:@grouped_measure_commodity_changes, collection)
      record
    end

    def grouped_measure_commodity_changes
      @grouped_measure_commodity_changes || super
    end

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
