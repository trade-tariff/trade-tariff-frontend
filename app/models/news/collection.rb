require 'api_entity'

module News
  class Collection
    include UkOnlyApiEntity

    set_collection_path 'api/v2/news/collections'

    attr_writer   :id
    attr_accessor :name,
                  :slug,
                  :description,
                  :priority

    enum :id, {
      trade_news: [1],
      tariff_notices: [2],
      tariff_stop_press: [3],
      service_updates: [4],
    }

    def id
      @id ||= resource_id.presence&.to_i
    end

    def to_param
      slug.presence || id
    end

    def matches_param?(collection_id)
      if collection_id.to_s.match? %r{\A\d+\z}
        id == collection_id.to_i
      elsif slug.present?
        slug == collection_id
      else
        false
      end
    end
  end
end
