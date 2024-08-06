module GreenLanes
  class StartsController < ApplicationController
    include GreenLanesHelper

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def new
      @check_your_answers_data = CheckYourAnswersData.new(commodity_code_data: { commodity_code: params[:commodity_code] })
    end

    def create
      redirect_to new_green_lanes_eligibility_path(check_your_answers_data: @check_your_answers_data.attributes)
    end
  end
end
