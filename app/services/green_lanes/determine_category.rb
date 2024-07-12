module GreenLanes
  class DetermineCategory
    CAT_1 = 1
    CAT_2 = 2

    attr_reader :goods_nomenclature

    def initialize(goods_nomenclature)
      @goods_nomenclature = goods_nomenclature
    end

    def categories
      return [:cat_3] if category_assessments.empty? # Result 3
      return [:cat_1] if cat1_without_exemptions.any? # Result 1

      # cat1_without_exemptions NO

      if cat2_without_exemptions.any?
        if cat1_with_exemptions.any?
          %i[cat_1 cat_2] # Result 4
        else
          [:cat_2] # Result 2
        end
      elsif cat1_with_exemptions.any? && cat2_with_exemptions.any?
        %i[cat_1 cat_2 cat_3] # Result 5
      elsif cat1_with_exemptions.any?
        %i[cat_1 cat_3] # Result 6
      elsif cat2_with_exemptions.any?
        %i[cat_2 cat_3] # Result 7
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
