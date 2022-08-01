require 'tariff_jsonapi_parser'
require 'errors'

module Beta
  module Search
    class PerformSearchService
      def initialize(query, filters = {})
        @query = query
        @filters = filters
      end

      def call
        retries = 0
        resp = api.get("/api/beta/search?q=#{@query}")
        parsed = parse_jsonapi(resp)

        Beta::Search::SearchResult.new(parsed)
      rescue Faraday::Error, UnparseableResponseError
        if retries < Rails.configuration.x.http.max_retry
          retries += 1
          retry
        else
          raise
        end
      end

      private

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
