module Beta
  module Search
    class FacetFilterStatisticCollection < SimpleDelegator
      delegate :new, to: :class

      delegate :beta_search_facet_filter_display_percentage_threshold,
               to: TradeTariffFrontend

      def initialize(facet_filter_statistics)
        @facet_filter_statistics = facet_filter_statistics.clone.presence || []
        @total_results = if facet_filter_statistics.any?
                           facet_filter_statistics.first.casted_by.total_results
                         else
                           0
                         end

        super @facet_filter_statistics
      end

      def applicable
        new(select(&method(:facet_filter_applicable?)))
      end

      private

      def facet_filter_applicable?(facet_filter_statistic)
        facet_percentage_of_total = calculate_percentage_of(
          @total_results,
          facet_filter_statistic.facet_count,
        )

        facet_percentage_of_total > beta_search_facet_filter_display_percentage_threshold
      end

      def calculate_percentage_of(total, value)
        return 0 if total.zero?

        (value / total.to_f * 100).round
      end
    end
  end
end
