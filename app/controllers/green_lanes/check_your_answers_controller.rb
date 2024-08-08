module GreenLanes
  class CheckYourAnswersController < ApplicationController
    include GreenLanesHelper

    before_action :check_green_lanes_enabled,
                  :disable_switch_service_banner,
                  :disable_search_form

    def show
      @commodity_code = check_your_answers_params[:commodity_code]
      @country_of_origin = check_your_answers_params[:country_of_origin] || GeographicalArea::ERGA_OMNES
      @moving_date = check_your_answers_params[:moving_date]
      @category_one_assessments = determine_category.cat1_with_exemptions
      @category_two_assessments = determine_category.cat2_with_exemptions
      @answers = check_your_answers_params[:ans]
      @c1ex = check_your_answers_params[:c1ex]
      @c2ex = check_your_answers_params[:c2ex]
      @back_link_path = determine_back_link_path(check_your_answers_params)
    end

    private

    def determine_back_link_path(permitted_params)
      cat_2_questions_exist = !permitted_params[:ans]['2'].nil?

      if all_exemptions_met?(1, @category_one_assessments, @answers) && cat_2_questions_exist
        new_green_lanes_applicable_exemptions_path(
          category: 2,
          commodity_code: permitted_params[:commodity_code],
          country_of_origin: permitted_params[:country_of_origin],
          moving_date: permitted_params[:moving_date],
          ans: permitted_params[:ans],
          c1ex: permitted_params[:c1ex],
          c2ex: permitted_params[:c2ex],
        )
      elsif permitted_params[:ans]['1'].nil?
        new_green_lanes_moving_requirements_path(
          commodity_code: permitted_params[:commodity_code],
          country_of_origin: permitted_params[:country_of_origin],
          moving_date: permitted_params[:moving_date],
        )
      else
        new_green_lanes_applicable_exemptions_path(
          category: 1,
          commodity_code: permitted_params[:commodity_code],
          country_of_origin: permitted_params[:country_of_origin],
          moving_date: permitted_params[:moving_date],
          ans: permitted_params[:ans],
          c1ex: permitted_params[:c1ex],
        )
      end
    end

    def determine_category
      @determine_category ||= DetermineCategory.new(goods_nomenclature)
    end

    def goods_nomenclature
      @goods_nomenclature ||= FetchGoodsNomenclature.new(check_your_answers_params).call
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
