module GreenLanes
  class FaqController < ApplicationController
    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form
    def index; end
  end
end
