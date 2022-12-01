require 'api_entity'

module News
  class Collection
    include UkOnlyApiEntity

    collection_path '/news/collections'

    attr_writer   :id
    attr_accessor :name,
                  :description,
                  :priority

    def id
      @id ||= resource_id.presence&.to_i
    end
  end
end
