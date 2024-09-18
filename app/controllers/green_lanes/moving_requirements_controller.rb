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
      }.merge(next_page_query)
       .merge(t: Time.zone.now.to_i)
       .deep_symbolize_keys

      "#{path}?#{query.to_query}"
    end
  end
end
