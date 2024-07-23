module GreenLanes
  class ResultsController < ApplicationController
    include GreenLanesHelper

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def show
      goods_nomenclature = GreenLanes::GoodsNomenclature.find(
        results_params[:commodity_code],
        { filter: { geographical_area_id: results_params[:country_of_origin] } },
        { authorization: TradeTariffFrontend.green_lanes_api_token },
      )

      @commodity_code = goods_nomenclature.goods_nomenclature_item_id
      @country_of_origin = results_params[:country_of_origin] || GeographicalArea::ERGA_OMNES
      @country_description = GeographicalArea.find(@country_of_origin).description
      @moving_date = results_params[:moving_date]

      next_page = DetermineNextPage
        .new(goods_nomenclature)
        .next(
          cat_1_exemptions_apply:,
          cat_2_exemptions_apply:,
        )

      case next_page
      when :result_cat_1
        render 'result_cat_1'
      when :result_cat_2
        render 'result_cat_2'
      when :result_cat_3
        render 'result_cat_3'
      end
    end

    private

    def result_params
      params.permit(
        :commodity_code,
        :country_of_origin,
        :moving_date,
        :c1ex,
        :c2ex,
      )
    end

    def cat_1_exemptions_apply
      case result_params[:c1ex]
      when 'true' then true
      when 'false' then false
      end
    end

    def cat_2_exemptions_apply
      case result_params[:c2ex]
      when 'true' then true
      when 'false' then false
      end
    end
  end
end
