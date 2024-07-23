module GreenLanes
  class MovingRequirementsController < ApplicationController
    include GreenLanesHelper

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def new
      @commodity_code = params[:commodity_code]
      @moving_requirements_form = MovingRequirementsForm.new(commodity_code: @commodity_code,
                                                             country_of_origin: params[:country_of_origin],
                                                             moving_date: params[:moving_date])
    end

    def create
      @moving_requirements_form = MovingRequirementsForm.new(moving_requirements_params)
      form = @moving_requirements_form

      if form.valid?
        next_page = DetermineNextPage
          .new(goods_nomenclature)
          .next

        path = case next_page
               when :cat_1_exemptions_questions
                 new_green_lanes_applicable_exemptions_path(
                   category: '1',
                   commodity_code: form.commodity_code,
                   moving_date: form.moving_date.iso8601,
                   country_of_origin: form.country_of_origin,
                 )
               when :cat_2_exemptions_questions
                 new_green_lanes_applicable_exemptions_path(
                   category: '2',
                   commodity_code: form.commodity_code,
                   moving_date: form.moving_date.iso8601,
                   country_of_origin: form.country_of_origin,
                 )
               else
                 redirect_to green_lanes_result_path(
                   commodity_code: form.commodity_code,
                   moving_date: form.moving_date.iso8601,
                   country_of_origin: form.country_of_origin,
                 )
               end

        redirect_to path
      else
        render 'new'
      end
    end

    private

    def moving_requirements_params
      params.require(:green_lanes_moving_requirements_form).permit(
        :commodity_code,
        :country_of_origin,
        :moving_date,
      )
    end

    def goods_nomenclature
      @goods_nomenclature ||= GreenLanes::GoodsNomenclature.find(
        moving_requirements_params[:commodity_code],
        {
          filter: {
            geographical_area_id: moving_requirements_params[:country_of_origin],
            as_of: @moving_requirements_form.moving_date.iso8601,
          },
          authorization: TradeTariffFrontend.green_lanes_api_token,
        },
      )
    end
  end
end
