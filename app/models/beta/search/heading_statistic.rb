module Beta
  module Search
    class HeadingStatistic
      include ApiEntity

      attr_accessor :description,
                    :cnt,
                    :score,
                    :avg,
                    :total_results,
                    :chapter_id,
                    :chapter_description,
                    :chapter_score
    end
  end
end
