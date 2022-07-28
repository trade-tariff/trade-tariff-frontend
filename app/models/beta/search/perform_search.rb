module Beta
  module Search
    class PerformSearch
      include ApiEntity

      def self.call(query)
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
