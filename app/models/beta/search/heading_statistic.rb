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

      def heading
        goods_nomenclature = Heading.new
        goods_nomenclature.goods_nomenclature_item_id = "#{resource_id}000000"
        goods_nomenclature
      end
    end
  end
end
