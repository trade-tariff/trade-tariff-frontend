module GreenLanes
  class FaqController < ApplicationController
    skip_before_action :set_search, only: [:index]
    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form
    def index; end
  end
end
