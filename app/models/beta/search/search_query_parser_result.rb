require 'api_entity'

module Beta
  module Search
    class SearchQueryParserResult
      include ApiEntity

      attr_accessor :original_search_query,
                    :corrected_search_query,
                    :adjectives,
                    :nouns,
                    :noun_chunks,
                    :verbs
    end
  end
end
