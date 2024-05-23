module GreenLanes
  class CheckMovingRequirementsController < ApplicationController
    before_action :check_moving_requirements,
                  :disable_switch_service_banner,
                  :disable_search_form

    def start
      @commodity_code = params[:code]
      render 'start'
    end

    def edit
      @commodity_code = params[:code]
      @check_moving_requirements_form = CheckMovingRequirementsForm.new(commodity_code: @commodity_code)

      render 'edit'
    end

    def update
      @check_moving_requirements_form = CheckMovingRequirementsForm.new(check_moving_requirements_params)
      form = @check_moving_requirements_form

      if form.valid?
        @goods_nomenclature = GreenLanes::GoodsNomenclature.find(
          form.commodity_code,
          {
            filter: { geographical_area_id: form.country_of_origin },
            as_of: form.moving_date,
          },
          { authorization: TradeTariffFrontend.green_lanes_api_token },
        )

        redirect_to result_green_lanes_check_moving_requirements_path(
          green_lanes_check_moving_requirements_form: {
            commodity_code: form.commodity_code,
            country_of_origin: form.country_of_origin,
            moving_date: form.moving_date,
          },
        )
      else
        render 'edit', status: :unprocessable_entity
      end
    rescue Faraday::ResourceNotFound
      flash[:error] = 'No result found for the given commodity code, country of origin and moving date.'
      render 'edit', status: :not_found
    end

    def result
      @goods_nomenclature = GreenLanes::GoodsNomenclature.find(
        check_moving_requirements_params[:commodity_code],
        { filter: { geographical_area_id: check_moving_requirements_params[:country_of_origin] } },
        { authorization: TradeTariffFrontend.green_lanes_api_token },
      )

      @commodity_code = @goods_nomenclature.goods_nomenclature_item_id
      @country_of_origin = check_moving_requirements_params[:country_of_origin]
      @moving_date = check_moving_requirements_params[:moving_date]

      @category = @goods_nomenclature.category

      render 'result'
    end

    private

    def check_moving_requirements_params
      params.require(:green_lanes_check_moving_requirements_form).permit(
        :commodity_code,
        :country_of_origin,
        :moving_date,
      )
    end

    def check_moving_requirements
      unless TradeTariffFrontend.green_lanes_enabled?
        raise TradeTariffFrontend::FeatureUnavailable
      end
    end
  end
end
