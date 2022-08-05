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

      def filter
        {
          filterable_key.to_sym => filterable_value,
        }
      end

      def filterable_display_name
        "Heading #{resource_id}"
      end

      def display_name
        description.html_safe
      end

      def filterable_key
        :heading_id
      end

      alias_method :filterable_value, :resource_id
      alias_method :count, :cnt
    end
  end
end
