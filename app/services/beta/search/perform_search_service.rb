require 'tariff_jsonapi_parser'
require 'errors'

module Beta
  module Search
    class PerformSearchService
      def initialize(query_options, filters = {})
        @query_options = query_options
        @filters = filters
      end

      def call
        path = "/api/beta/search?#{query_params}"
        response = api.get(path)
        parsed = parse_jsonapi(response)

        Beta::Search::SearchResult.new(parsed)
      end

      private

      def query_params
        @query_params = @query_options.merge(filter_query)
        @query_params.to_query
      end

      def filter_query
        @filter_query = @filters.transform_keys do |filter_name|
          "filter[#{filter_name}]"
        end

        @filter_query = @filter_query.transform_values do |filter_values|
          Array.wrap(filter_values).join(',')
        end
      end

      def parse_jsonapi(resp)
        TariffJsonapiParser.new(resp.body).parse
      rescue TariffJsonapiParser::ParsingError
        raise UnparseableResponseError, resp
      end

      def api
        TradeTariffFrontend::ServiceChooser.api_client
      end
    end
  end
end
