require 'api_entity'

module News
  class Year
    include UkOnlyApiEntity

    attr_accessor :year
  end
end
