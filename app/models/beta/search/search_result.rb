# https://dev.trade-tariff.service.gov.uk/uk/api/beta/search?q=clothing%20sets
module Beta
  module Search
    class SearchResult
      include ApiEntity

      attr_accessor :id,
                    :took,
                    :timed_out,
                    :max_score,
                    :total_results

      has_many :chapter_statistics, class: 'Beta::Search::ChapterStatistic'
      has_many :heading_statistics, class: 'Beta::Search::HeadingStatistic'
      has_many :hits, class: 'Beta::Search::Hit'
      has_one :guide, class: 'Beta::Search::Guide'
      has_one :search_query_parser_result, class: 'Beta::Search::SearchQueryParserResult'

      def build(query)
        retries = 0
        resp = api.get("/api/beta/search?q=#{query}")
        parsed = parse_jsonapi(resp)
        new(parsed)
      rescue Faraday::Error, ApiEntity::UnparseableResponseError
        if retries < Rails.configuration.x.http.max_retry
          retries += 1
          retry
        else
          raise
        end
      end
    end
  end
end
