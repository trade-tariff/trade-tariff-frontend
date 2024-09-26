module GreenLanes
  class DetermineCandidateCategories
    def initialize(goods_nomenclature)
      @goods_nomenclature = goods_nomenclature
    end

    def categories
      return [3] if category_assessments.empty?
      return [1] if cat1_without_exemptions.any?

      if cat2_without_exemptions.any?
        if cat1_with_exemptions.any?
          [1, 2]
        else
          [2]
        end
      elsif cat1_with_exemptions.any? && cat2_with_exemptions.any?
        [1, 2, 3]
      elsif cat1_with_exemptions.any?
        [1, 3]
      elsif cat2_with_exemptions.any?
        [2, 3]
      end
    end

    def cat1_without_exemptions
      without_exemptions(category_assessments(1))
    end

    def cat2_without_exemptions
      without_exemptions(category_assessments(2))
    end

    def cat1_with_exemptions
      with_exemptions(category_assessments(1))
    end

    def cat2_with_exemptions
      with_exemptions(category_assessments(2))
    end

    private

    attr_reader :goods_nomenclature

    def without_exemptions(assessments)
      assessments.select { |ca| ca.exemptions.empty? }
    end

    def with_exemptions(assessments)
      assessments.select { |ca| ca.exemptions.any? }
    end

    def category_assessments(category = nil)
      # binding.pry
      descendents = goods_nomenclature.descendants

      ca_assessments = if descendents.count.positive?
                         goods_nomenclature.applicable_category_assessments + goods_nomenclature.descendant_category_assessments
                       else
                         goods_nomenclature.applicable_category_assessments
                       end

      return ca_assessments unless category

      ca_assessments.select { |ca| ca.category == category }
    end
  end
end
