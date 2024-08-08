module GreenLanes
  class EligibilityResult
    YOU_MAY_BE_ELIGIBLE = 'you_may_be_eligible'.freeze
    NOT_YET_ELIGIBLE = 'not_yet_eligible'.freeze
    NOT_ELIGIBLE = 'not_eligible'.freeze

    NOT_SURE = 'not_sure'.freeze
    YES = 'yes'.freeze

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

    def not_yet_eligible?
      all_conditions_met_except_ukims? || end_consumers_not_sure?
    end

    def may_be_eligible?
      all_positive_conditions_met?
    end

    def all_positive_conditions_met?
      [@moving_goods_gb_to_ni, @free_circulation_in_uk, @end_consumers_in_uk == true, @ukims].all?
    end

    def all_conditions_met_except_ukims?
      [@moving_goods_gb_to_ni, @free_circulation_in_uk, @end_consumers_in_uk].all? && !@ukims
    end

    def end_consumers_not_sure?
      @moving_goods_gb_to_ni && @free_circulation_in_uk && @end_consumers_in_uk == NOT_SURE
    end

    def normalize_answer(response)
      case response.downcase
      when YES then true
      when NOT_SURE then NOT_SURE
      else false
      end
    end
  end
end
