module GreenLanes
  class DetermineNextPage
    def initialize(goods_nomenclature)
      @categories = GreenLanes::DetermineCategory.new(goods_nomenclature).categories
    end

    def next(cat_1_exemptions_apply: nil, cat_2_exemptions_apply: nil)
      case @categories
      when [:cat_1], [:cat_2], [:cat_3]
        # Simplest case: only one category is present
        # "result_#{@categories.first}".to_sym
        "/green_lanes/results/#{@categories.first}"
      when %i[cat_1 cat_2]
        # Questions Cat 1 exemptions has not been answered

        return :cat_1_exemptions_questions if question_unanswered?(cat_1_exemptions_apply)

        if cat_1_exemptions_apply
          '/green_lanes/results/2'
        else
          '/green_lanes/results/1'
        end
      when %i[cat_1 cat_2 cat_3]
        # Questions Cat 1 exemptions has not been answered
        return :cat_1_exemptions_questions if question_unanswered?(cat_1_exemptions_apply)

        if cat_1_exemptions_apply
          :cat_2_exemptions_questions
        else
          '/green_lanes/results/1'
        end
      when %i[cat_2 cat_3]
        return :cat_2_exemptions_questions if question_unanswered?(cat_2_exemptions_apply)

        if cat_2_exemptions_apply
          :result_cat_3
        else
          :result_cat_2
        end
      else
        raise 'Impossible to determine next page'
      end
    end

    private

    def question_unanswered?(cat_exemptions_apply)
      cat_exemptions_apply.nil?
    end
  end
end

# result.size > 1 -> question page

# result.size == 1 -> result page + catX as param
