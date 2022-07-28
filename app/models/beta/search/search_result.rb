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

      has_many :chapter_statistics, class_name: 'Beta::Search::ChapterStatistic'
      has_many :heading_statistics, class_name: 'Beta::Search::HeadingStatistic'
      has_many :hits, polymorphic: true # TODO: test this!
      has_one :guide, class_name: 'Beta::Search::Guide'
      has_one :search_query_parser_result, class_name: 'Beta::Search::SearchQueryParserResult'
    end
  end
end
