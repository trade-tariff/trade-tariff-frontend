module GreenLanes
  class EligibilityResultsController < ApplicationController
    include GreenLanesHelper

    include Concerns::ExpirableUrl

    before_action :check_green_lanes_enabled,
                  :page_has_not_expired,
                  :disable_switch_service_banner,
                  :disable_search_form

    def new
      @result = GreenLanes::EligibilityResult.new(eligibility_params).call
    end

    private

    def eligibility_params
      params.permit(
        :moving_goods_gb_to_ni,
        :free_circulation_in_uk,
        :end_consumers_in_uk,
        :ukims,
      )
    end
  end
end
