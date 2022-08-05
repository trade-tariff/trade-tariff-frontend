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
          facet.to_sym => classification,
        }
      end
    end
  end
end
