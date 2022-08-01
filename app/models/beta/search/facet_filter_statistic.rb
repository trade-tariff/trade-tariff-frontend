require 'api_entity'

module Beta
  module Search
    class FacetFilterStatistic
      include ApiEntity

      attr_accessor :facet_filter,
                    :facet_count,
                    :display_name,
                    :question

      has_many :facet_classification_statistics, class_name: 'Beta::Search::FacetClassificationStatistic'
    end
  end
end
