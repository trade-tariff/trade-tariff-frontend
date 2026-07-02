module GreenLanes
  module Concerns
    module NextPageNavigation
      extend ActiveSupport::Concern

      private

      # Builds the redirect URL for the next Green Lanes wizard page.
      #
      # next_page is a full URL string returned by DetermineNextPage. We strip it
      # to its path, then merge base query params (supplied by the including
      # controller via next_page_base_query_params), any query string already
      # present on the next_page URL, and a cache-busting timestamp.
      def handle_next_page(next_page)
        uri = URI(next_page)
        path = uri.path
        next_page_query = uri.query ? Rack::Utils.parse_query(uri.query) : {}

        query = next_page_base_query_params
          .merge(next_page_query)
          .merge(next_page_extra_query_params)
          .merge(t: Time.zone.now.to_i)
          .deep_symbolize_keys

        "#{path}?#{query.to_query}"
      end

      # Override in each including controller to supply the base query params
      # that must be threaded through every wizard redirect.
      def next_page_base_query_params
        raise NotImplementedError, "#{self.class}#next_page_base_query_params must be implemented"
      end

      # Override in each including controller to supply any additional query
      # params that should be merged in after the next-page URL's own query
      # string. Defaults to an empty hash.
      def next_page_extra_query_params
        {}
      end
    end
  end
end
