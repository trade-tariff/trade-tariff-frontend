module GreenLanes
  class DetermineCategory
    attr_reader :goods_nomenclature

    def initialize(goods_nomenclature)
      @goods_nomenclature = goods_nomenclature
    end

    def call
      return [:cat_3] if category_assessments.empty? # Result 3

      if cat1_without_exemptions.any?
        [:cat_1] # Result 1
      elsif cat2_without_exemptions.any?
        if cat1_with_exemptions.any?
          %i[cat_1 cat_2] # Result 4
        else
          [:cat_2] # Result 2
        end
      elsif cat1_with_exemptions.any?
        if cat2_with_exemptions.any?
          %i[cat_1 cat_2 cat_3] # Result 5
        else
          %i[cat_1 cat_3] # Result 6
        end
      elsif cat2_with_exemptions.any?
        %i[cat_2 cat_3]
      end
    end

    private

    def cat1_assessments
      category_assessments.select { |ca| ca.theme.category == 1 }
    end

    def cat2_assessments
      category_assessments.select { |ca| ca.theme.category == 2 }
    end

    def category_assessments
      goods_nomenclature.applicable_category_assessments
    end

    def cat1_without_exemptions
      cat1_assessments.select { |ca| ca.exemptions.empty? }
    end

    def cat2_without_exemptions
      cat2_assessments.select { |ca| ca.exemptions.empty? }
    end

    def cat1_with_exemptions
      cat1_assessments.select { |ca| ca.exemptions.any? }
    end

    def cat2_with_exemptions
      cat2_assessments.select { |ca| ca.exemptions.any? }
    end
  end
end
