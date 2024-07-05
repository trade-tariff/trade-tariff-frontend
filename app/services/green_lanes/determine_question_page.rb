module GreenLanes
  class DetermineQuestionPage
    def initialize(goods_nomenclature)
      @categories = GreenLanes::DetermineCategory.new(goods_nomenclature).categories
    end

    def next_page
      case @categories
      when [:cat_1], [:cat_2], [:cat_3]
        :result
      when %i[cat_1 cat_2],
           %i[cat_1 cat_2 cat_3]
        :cat_1_exemptions_questions
      when %i[cat_2 cat_3]
        :cat_2_exemptions_questions
      else
        raise 'Impossible to determine next page'
      end
    end
  end
end
