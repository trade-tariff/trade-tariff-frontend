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

      def facet
        facet_filter.sub('filter_', '')
      end

      def find_classification(classification)
        facet_classification_statistics.find do |facet_classification_statistic|
          facet_classification_statistic.classification == classification
        end
      end
    end
  end
end
