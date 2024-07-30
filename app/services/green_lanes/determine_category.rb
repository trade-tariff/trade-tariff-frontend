module GreenLanes
  class DetermineCategory
    CAT_1 = 1
    CAT_2 = 2
    CAT_3 = 3

    def initialize(goods_nomenclature)
      @goods_nomenclature = goods_nomenclature
    end

    def categories
      return [CAT_3] if category_assessments.empty?
      return [CAT_1] if cat1_without_exemptions.any?

      if cat2_without_exemptions.any?
        if cat1_with_exemptions.any?
          [CAT_1, CAT_2]
        else
          [CAT_2]
        end
      elsif cat1_with_exemptions.any? && cat2_with_exemptions.any?
        [CAT_1, CAT_2, CAT_3]
      elsif cat1_with_exemptions.any?
        [CAT_1, CAT_3]
      elsif cat2_with_exemptions.any?
        [CAT_2, CAT_3]
      end
    end

    def cat1_without_exemptions
      without_exemptions(category_assessments(CAT_1))
    end

    def cat2_without_exemptions
      without_exemptions(category_assessments(CAT_2))
    end

    def cat1_with_exemptions
      with_exemptions(category_assessments(CAT_1))
    end

    def cat2_with_exemptions
      with_exemptions(category_assessments(CAT_2))
    end

    private

    attr_reader :goods_nomenclature

    def without_exemptions(cat_assessments)
      cat_assessments.select { |ca| ca.exemptions.empty? }
    end

    def with_exemptions(cat_assessments)
      cat_assessments.select { |ca| ca.exemptions.any? }
    end

    def category_assessments(category = nil)
      ca_assessments = goods_nomenclature.applicable_category_assessments

      return ca_assessments unless category

      ca_assessments.select { |ca| ca.category == category }
    end
  end
end
