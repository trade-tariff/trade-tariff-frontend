require 'api_entity'

module Beta
  module Search
    class SearchResult
      include ApiEntity

      attr_accessor :took,
                    :timed_out,
                    :max_score,
                    :total_results,
                    :meta

      meta_attribute :redirect
      meta_attribute :redirect_to

      alias_method :redirect?, :redirect

      has_many :chapter_statistics, class_name: 'Beta::Search::ChapterStatistic'
      has_many :heading_statistics, class_name: 'Beta::Search::HeadingStatistic', wrapper: Beta::Search::HeadingStatisticCollection
      has_many :hits, polymorphic: true, wrapper: Beta::Search::HitsCollection
      has_many :facet_filter_statistics, class_name: 'Beta::Search::FacetFilterStatistic'
      has_one :guide, class_name: 'Beta::Search::Guide'
      has_one :search_query_parser_result, class_name: 'Beta::Search::SearchQueryParserResult'

      def multiple_headings_view?
        heading_statistics.count > TradeTariffFrontend.beta_search_heading_statistics_threshold
      end

      def applicable_facet_filter_statistics
        facet_filter_statistics.select { |facet_filter_statistic| facet_filter_statistic.facet_classification_statistics.many? }
      end

      def classification_for(facet, classification)
        return if facet_filter_statistics.none?

        filter = facet_filter_statistics.find do |facet_filter_statistic|
          facet_filter_statistic.facet.to_sym == facet
        end

        filter.find_classification(classification)
      end
    end
  end
end
