module GreenLanes
  class CheckYourAnswersController < ApplicationController
    include GreenLanesHelper

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def new
      @commodity_code = check_your_answers_params[:commodity_code]
      @country_of_origin = check_your_answers_params[:country_of_origin] || GeographicalArea::ERGA_OMNES
      @moving_date = check_your_answers_params[:moving_date]
      @category_one_assessments = determine_category.cat1_with_exemptions
      @category_two_assessments = determine_category.cat2_with_exemptions
      @answers = check_your_answers_params[:ans]
      @c1ex = check_your_answers_params[:c1ex]
      @c2ex = check_your_answers_params[:c2ex]
    end

    private

    def determine_category
      @determine_category ||= DetermineCategory.new(goods_nomenclature)
    end

    def goods_nomenclature
      @goods_nomenclature ||= GoodsNomenclature.find(check_your_answers_params[:commodity_code])
    end

    def check_your_answers_params
      params.permit(
        :commodity_code,
        :country_of_origin,
        :moving_date,
        :c1ex,
        :c2ex,
        ans: {},
      )
    end
  end
end
