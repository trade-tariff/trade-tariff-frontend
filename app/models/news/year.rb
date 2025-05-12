require 'api_entity'

module News
  class Year
    include UkOnlyApiEntity

    set_collection_path 'api/v2/news/years'

    attr_accessor :year
  end
end
