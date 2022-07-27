require 'api_entity'

module Beta
  module Search
    class ChapterStatistic
      include ApiEntity

      attr_accessor :description,
                    :cnt,
                    :score,
                    :avg,
                    :total_results
    end
  end
end
