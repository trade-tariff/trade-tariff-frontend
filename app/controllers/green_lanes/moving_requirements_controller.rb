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

    def handle_next_page(next_page)
      uri = URI(next_page)
      path = uri.path
      next_page_query = if uri.query
                          CGI.parse(uri.query).transform_values(&:first)
                        else
                          {}
                        end

      query = {
        commodity_code: moving_requirements_params[:commodity_code],
        country_of_origin: moving_requirements_params[:country_of_origin],
        moving_date: @moving_requirements_form.moving_date.iso8601,
      }
        .merge(next_page_query)
        .deep_symbolize_keys

      "#{path}?#{query.to_query}"
    end
  end
end
