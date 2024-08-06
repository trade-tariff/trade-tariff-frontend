module GreenLanes
  class EligibilityResultsController < ApplicationController
    include GreenLanesHelper

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def new
      @check_your_answers_data = CheckYourAnswersData.new(parse_json_params(params[:check_your_answers_data]))
      @result = GreenLanes::EligibilityResult.new(@check_your_answers_data.eligibility_data).call
    end
  end
end
