module GreenLanes
  class EligibilitiesController < ApplicationController
    include GreenLanesHelper

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def new
      @commodity_code = params[:commodity_code]
      @eligibility_form = EligibilityForm.new(moving_goods_gb_to_ni: params[:moving_goods_gb_to_ni],
                                              free_circulation_in_uk: params[:free_circulation_in_uk],
                                              end_consumers_in_uk: params[:end_consumers_in_uk],
                                              ukims: params[:ukims])
    end

    def create
      @eligibility_form = EligibilityForm.new(eligibility_params)

      if @eligibility_form.valid?
        redirect_to green_lanes_eligibility_result_path(
          eligibility_params.merge(t: Time.zone.now.to_i),
        )
      else
        render 'new'
      end
    end

    private

    def eligibility_params
      params.require(:green_lanes_eligibility_form).permit(
        :moving_goods_gb_to_ni,
        :free_circulation_in_uk,
        :end_consumers_in_uk,
        :ukims,
      )
    end
  end
end
