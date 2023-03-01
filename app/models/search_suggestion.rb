require 'api_entity'

class SearchSuggestion
  include ApiEntity

  collection_path '/search_suggestions'

  attr_accessor :score, :query, :value
end
