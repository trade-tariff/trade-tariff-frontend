require 'api_entity'

module News
  class Collection
    include ApiEntity

    attr_accessor :name
  end
end
