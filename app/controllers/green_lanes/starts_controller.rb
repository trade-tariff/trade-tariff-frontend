module GreenLanes
  class StartsController < ApplicationController
    include GreenLanesHelper

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def new
      @commodity_code = params[:commodity_code]
    end
  end
end
