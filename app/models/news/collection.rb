require 'api_entity'

module News
  class Collection
    include UkOnlyApiEntity

    collection_path '/news/collections'

    attr_writer   :id
    attr_accessor :name,
                  :slug,
                  :description,
                  :priority

    def id
      @id ||= resource_id.presence&.to_i
    end

    def to_param
      slug.presence || id
    end
  end
end
