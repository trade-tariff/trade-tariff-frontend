require 'api_entity'

module Beta
  module Search
    class FacetClassificationStatistic
      include ApiEntity

      attr_accessor :facet,
                    :classification,
                    :count
    end
  end
end
