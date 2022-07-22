module Beta
  module Search
    class SearchQueryParserResult
      include ApiEntity

      attr_accessor :id,
                    :took,
                    :timed_out,
                    :max_score,
                    :total_results
    end
  end
end
