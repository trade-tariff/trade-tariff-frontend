require 'api_entity'

module News
  class Year
    include UkOnlyApiEntity

    collection_path '/news/years'

    attr_accessor :year
  end
end
