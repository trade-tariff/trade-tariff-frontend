require 'api_entity'

module Beta
  module Search
    class Guide
      include ApiEntity

      attr_accessor :title,
                    :url,
                    :strapline,
                    :image
    end
  end
end
