require 'api_entity'

module News
  class Collection
    include UkOnlyApiEntity

    collection_path '/news/collections'

    attr_accessor :name
    attr_writer   :id

    def id
      @id ||= resource_id.presence&.to_i
    end
  end
end
