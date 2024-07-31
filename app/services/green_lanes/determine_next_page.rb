module GreenLanes
  class DetermineNextPage
    def initialize(goods_nomenclature)
      @categories = GreenLanes::DetermineCategory.new(goods_nomenclature).categories
    end

    def next(cat_1_exemptions_apply: nil,
             cat_2_exemptions_apply: nil)

      return check_your_answers if @categories == [3]

      handle_cat1_cat2(cat_1_exemptions_apply) if single_category?

      case @categories
      when [1, 2]
        handle_cat1_cat2(cat_1_exemptions_apply)
      when [1, 2, 3]
        handle_all_categories(cat_1_exemptions_apply, cat_2_exemptions_apply)
      when [2, 3]
        handle_cat2_cat3(cat_2_exemptions_apply)
      else
        raise 'Impossible to determine next page'
      end
    end

    private

    def single_category?
      @categories.size == 1
    end

    def handle_cat1_cat2(cat_1_exemptions_apply)
      return new_exemptions_path(1) if question_unanswered?(cat_1_exemptions_apply)

      check_your_answers
    end

    def handle_all_categories(cat_1_exemptions_apply, cat_2_exemptions_apply)
      return new_exemptions_path(1) if question_unanswered?(cat_1_exemptions_apply)
      return new_exemptions_path(2, c1ex: true) if cat_1_exemptions_apply && question_unanswered?(cat_2_exemptions_apply)

      check_your_answers
    end

    def handle_cat2_cat3(cat_2_exemptions_apply)
      return new_exemptions_path(2) if question_unanswered?(cat_2_exemptions_apply)

      check_your_answers
    end

    def question_unanswered?(cat_exemptions_apply)
      cat_exemptions_apply.nil?
    end

    def new_exemptions_path(category, params = {})
      query = params.to_query

      "/green_lanes/applicable_exemptions/new?category=#{category}" + (query.present? ? "&#{query}" : '')
    end

    def check_your_answers
      '/green_lanes/check_your_answers/new'
    end
  end
end
