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

    # Category assessments having exemptions that are not met
    def cas_with_exemptions_that_are_not_met(answers)
      non_met_ca_ids = answers ? answers.select{|k, v| v == ['none'] }.keys : []
      cat2_with_exemptions.select{ |ca| non_met_ca_ids.include?(ca.resource_id) }
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
      ca_assessments = goods_nomenclature.applicable_category_assessments

      return ca_assessments unless category

      ca_assessments.select { |ca| ca.category == category }
    end
  end
end
