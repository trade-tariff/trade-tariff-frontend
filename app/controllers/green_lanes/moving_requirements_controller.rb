module GreenLanes
  class MovingRequirementsController < ApplicationController
    include GreenLanesHelper

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def new
      set_moving_requirements_form
    end

    def create
      @moving_requirements_form = MovingRequirementsForm.new(moving_requirements_params)

      if @moving_requirements_form.valid?
        redirect_to_next_page
      else
        render 'new'
      end
    end

    def edit
      set_moving_requirements_form
    end

    def update
      set_moving_requirements_form

      original_attributes = {
        commodity_code: params[:original_commodity_code],
        country_of_origin: params[:original_country_of_origin],
        moving_date: params[:original_moving_date].to_date,
      }.symbolize_keys

      updated_attributes = moving_requirements_params.to_h.symbolize_keys

      updated_attributes[:moving_date] = Date.new(
        updated_attributes.delete(:"moving_date(1i)").to_i,
        updated_attributes.delete(:"moving_date(2i)").to_i,
        updated_attributes.delete(:"moving_date(3i)").to_i,
      )

      if original_attributes == updated_attributes
        redirect_to green_lanes_check_your_answers_path(
          commodity_code: original_attributes[:commodity_code],
          country_of_origin: original_attributes[:country_of_origin],
          moving_date: original_attributes[:moving_date].iso8601,
          ans: params[:ans],
          c1ex: params[:c1ex],
          c2ex: params[:c2ex],
        )
      else
        @moving_requirements_form.assign_attributes(updated_attributes)

        if @moving_requirements_form.valid?
          redirect_to_next_page
        else
          render 'edit'
        end
      end
    end

    private

    def redirect_to_next_page
      next_page = DetermineNextPage.new(goods_nomenclature).next
      redirect_to handle_next_page(next_page)
    end

    def set_moving_requirements_form
      @commodity_code = params[:commodity_code]
      @moving_requirements_form = MovingRequirementsForm.new(
        commodity_code: @commodity_code,
        country_of_origin: params[:country_of_origin],
        moving_date: params[:moving_date],
      )
    end

    def moving_requirements_params
      params.require(:green_lanes_moving_requirements_form).permit(
        :commodity_code,
        :country_of_origin,
        :moving_date,
      )
    end

    def goods_nomenclature
      @goods_nomenclature ||= FetchGoodsNomenclature.new(moving_requirements_params).call
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
