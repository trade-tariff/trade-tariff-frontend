module GreenLanes
  class DetermineNextPage
    def initialize(goods_nomenclature)
      @categories = GreenLanes::DetermineCategory.new(goods_nomenclature).categories
    end

    def next(cat_1_exemptions_apply: nil, cat_2_exemptions_apply: nil)
      case @categories
      when [1], [2], [3]
        # Simplest case: only one category is present
        # "result_#{@categories.first}".to_sym
        "/green_lanes/results/#{@categories.first}"
      when [1, 2]
        # Questions Cat 1 exemptions has not been answered
        return '/green_lanes/applicable_exemptions/new?category=1' if question_unanswered?(cat_1_exemptions_apply)

        if cat_1_exemptions_apply
          '/green_lanes/results/2'
        else
          '/green_lanes/results/1'
        end
      when [1, 2, 3]
        # Questions Cat 1 exemptions has not been answered
        return '/green_lanes/applicable_exemptions/new?category=1' if question_unanswered?(cat_1_exemptions_apply)

        if cat_1_exemptions_apply && cat_2_exemptions_apply
          '/green_lanes/results/3'
        elsif cat_1_exemptions_apply && question_unanswered?(cat_2_exemptions_apply)
          '/green_lanes/applicable_exemptions/new?category=2&c1ex=true'
        elsif cat_1_exemptions_apply && !cat_2_exemptions_apply
          '/green_lanes/results/2'
        else
          '/green_lanes/results/1'
        end
      when [2, 3]
        return '/green_lanes/applicable_exemptions/new?category=2' if question_unanswered?(cat_2_exemptions_apply)

        if cat_2_exemptions_apply
          '/green_lanes/results/3'
        else
          '/green_lanes/results/2'
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
