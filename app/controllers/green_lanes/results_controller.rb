module GreenLanes
  class ResultsController < ApplicationController
    include GreenLanesHelper

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form,
                  only: :create

    def create
      @commodity_code = goods_nomenclature.goods_nomenclature_item_id
      @country_of_origin = results_params[:country_of_origin] || GeographicalArea::ERGA_OMNES
      @moving_date = results_params[:moving_date]
      @category = category
      @answers = JSON.parse(results_params[:ans].presence || '{}')
      @assessments = AssessmentsPresenter.new(determine_category, @ans)
    end

    private

    def results_params
      params.permit(
        :commodity_code,
        :country_of_origin,
        :moving_date,
        :c1ex,
        :c2ex,
        :category,
        :ans,
      )
    end

    def determine_category
      @determine_category ||= DetermineCategory.new(goods_nomenclature)
    end

    def goods_nomenclature
      @goods_nomenclature ||= GreenLanes::FetchGoodsNomenclature.new(results_params).call
    end

    def category
      results_params[:category] || determine_category.categories.first
    end
  end
end
