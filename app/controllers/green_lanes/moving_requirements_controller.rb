module GreenLanes
  class MovingRequirementsController < ApplicationController
    include GreenLanesHelper

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def new
      @check_your_answers_data = CheckYourAnswersData.new(parse_json_params(params[:check_your_answers_data]))
      @moving_requirements_form = MovingRequirementsForm.new(
        commodity_code: @commodity_code,
        country_of_origin: params[:country_of_origin],
        moving_date: params[:moving_date],
      )
    end

    def create
      @moving_requirements_form = MovingRequirementsForm.new(moving_requirements_params)

      if @moving_requirements_form.valid?
        @check_your_answers_data = CheckYourAnswersData.new(parse_json_params(params[:check_your_answers_data]))
        @check_your_answers_data.moving_requirements_data = @moving_requirements_form.attributes

        next_page = DetermineNextPage.new(goods_nomenclature).next

        redirect_to handle_next_page(next_page, @check_your_answers_data.attributes)
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
      @goods_nomenclature ||= FetchGoodsNomenclature.new(moving_requirements_params).call
    end

    def handle_next_page(next_page, check_your_answers_data)
      uri = URI(next_page)
      path = uri.path
      next_page_query = uri.query ? CGI.parse(uri.query).transform_values(&:first) : {}

      query = {
        check_your_answers_data:,
      }.merge(next_page_query).deep_symbolize_keys

      "#{path}?#{query.to_query}"
    end
  end
end
