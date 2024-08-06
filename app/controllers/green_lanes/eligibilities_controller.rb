module GreenLanes
  class EligibilitiesController < ApplicationController
    include GreenLanesHelper

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def new
      @check_your_answers_data = CheckYourAnswersData.new(parse_json_params(params[:check_your_answers_data]))
      @eligibility_form = EligibilityForm.new(eligibility_params)
    end

    def create
      @check_your_answers_data = CheckYourAnswersData.new(parse_json_params(params[:check_your_answers_data]))
      @eligibility_form = EligibilityForm.new(eligibility_params)

      if @eligibility_form.valid?
        @check_your_answers_data.eligibility_data = @eligibility_form.attributes

        redirect_to new_green_lanes_eligibility_result_path(check_your_answers_data: @check_your_answers_data.attributes)
      else
        render 'new'
      end
    end

    private

    def eligibility_params
      params.require(:green_lanes_eligibility_form).permit(:moving_goods_gb_to_ni, :free_circulation_in_uk, :end_consumers_in_uk, :ukims)
    end
  end
end
