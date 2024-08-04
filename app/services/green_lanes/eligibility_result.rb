module GreenLanes
  class EligibilityResult
    YOU_MAY_BE_ELIGIBLE = 'you_may_be_eligible'.freeze
    NOT_YET_ELIGIBLE = 'not_yet_eligible'.freeze
    NOT_ELIGIBLE = 'not_eligible'.freeze

    POSITIVE_RESPONSES = %w[yes not_sure].freeze

    def initialize(params)
      @moving_goods_gb_to_ni = normalize_answer(params[:moving_goods_gb_to_ni])
      @free_circulation_in_uk = normalize_answer(params[:free_circulation_in_uk])
      @end_consumers_in_uk = normalize_answer(params[:end_consumers_in_uk])
      @ukims = normalize_answer(params[:ukims])
    end

    def call
      return YOU_MAY_BE_ELIGIBLE if may_be_eligible?
      return NOT_YET_ELIGIBLE if not_yet_eligible?

      NOT_ELIGIBLE
    end

    private

    def not_eligible?
      !@moving_goods_gb_to_ni || !@free_circulation_in_uk || !@end_consumers_in_uk
    end

    def not_yet_eligible?
      all_positive_conditions_met? && !@ukims
    end

    def may_be_eligible?
      all_positive_conditions_met? && @ukims
    end

    def all_positive_conditions_met?
      @moving_goods_gb_to_ni && @free_circulation_in_uk && @end_consumers_in_uk
    end

    def normalize_answer(response)
      POSITIVE_RESPONSES.include?(response.downcase)
    end
  end
end
