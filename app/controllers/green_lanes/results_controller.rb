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
      # TODO: THIS IS STILL NOT WORKING!!!!!
      @answers = JSON.parse(params[:ans].presence || '{}')
      @assessments = AssessmentsPresenter.new(determine_category, @answers)
    end

    private

    def results_params
      parsed_ans = JSON.parse(params[:ans]) if params[:ans].present? && !params.is_a?(ActionController::Parameters)
      params[:ans] = parsed_ans if parsed_ans

      params.permit(
        :commodity_code,
        :country_of_origin,
        :moving_date,
        :c1ex,
        :c2ex,
        ans: permit_dynamic_ans(parsed_ans),
      )
    end

    def determine_category
      @determine_category ||= DetermineCategory.new(goods_nomenclature)
    end

    def goods_nomenclature
      @goods_nomenclature ||= GreenLanes::FetchGoodsNomenclature.new(results_params).call
    end

    def category
      DetermineResultingCategory.new(categories, c1ex, c2ex).call.to_s
    end

    def categories
      @categories ||= determine_category.categories
    end

    def c1ex
      results_params[:c1ex]
    end

    def c2ex
      results_params[:c2ex]
    end

    def permit_dynamic_ans(params)
      if params.is_a?(Hash)
        params.each_key do |key|
          params[key] = params[key].is_a?(Hash) ? permit_dynamic_ans(params[key]) : params[key]
        end
      end
      params
    end
  end
end
