require 'api_entity'

module Beta
  module Search
    class FacetClassificationStatistic
      include ApiEntity

      attr_accessor :facet,
                    :classification,
                    :count

      def filter
        {
          filterable_key.to_sym => filterable_value,
        }
      end

      def display_name
        classification.humanize
      end

      alias_method :filterable_key, :facet
      alias_method :filterable_value, :classification
      alias_method :filterable_display_name, :display_name
    end
  end
end
