module GreenLanes
  class DetermineCategory
    def self.call(goods_nomenclature)
      if goods_nomenclature.applicable_category_assessments.empty?
        :cat_3
      end
    end
  end
end
