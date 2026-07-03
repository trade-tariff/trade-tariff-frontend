module GreenLanes
  class MovingRequirementsController < ApplicationController
    include GreenLanesHelper
    include Concerns::NextPageNavigation

    before_action :disable_switch_service_banner,
                  :disable_search_form

    def new
      @commodity_code = params[:commodity_code]
      @moving_requirements_form = MovingRequirementsForm.new(commodity_code: @commodity_code,
                                                             country_of_origin: params[:country_of_origin],
                                                             moving_date: params[:moving_date])
    end

    def create
      @moving_requirements_form = MovingRequirementsForm.new(moving_requirements_params)

      if @moving_requirements_form.valid?
        next_page = DetermineNextPage
          .new(goods_nomenclature)
          .next

        redirect_to handle_next_page(next_page)
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
      @goods_nomenclature ||= FetchGoodsNomenclature.new(goods_nomenclature_params).call
    end

    def goods_nomenclature_params
      {
        commodity_code: moving_requirements_params[:commodity_code],
        country_of_origin: moving_requirements_params[:country_of_origin],
        moving_date: @moving_requirements_form.moving_date,
      }
    end

    def next_page_base_query_params
      {
        commodity_code: moving_requirements_params[:commodity_code],
        country_of_origin: moving_requirements_params[:country_of_origin],
        moving_date: @moving_requirements_form.moving_date.iso8601,
      }
    end
  end
end
