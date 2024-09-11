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

      @category_one_assessments = candidate_categories.cat1_with_exemptions
      @category_two_assessments = candidate_categories.cat2_with_exemptions
      @category_two_assessments_without_exemptions = candidate_categories.cat2_without_exemptions

      @resulting_category = prettify_category(resulting_category)

      @answers = check_your_answers_params[:ans]
      @c1ex = check_your_answers_params[:c1ex]
      @c2ex = check_your_answers_params[:c2ex]
      @back_link_path = back_link_path_for_current_page
    end

    private

    def back_link_path_for_current_page
      BackLinkPath.new(params: check_your_answers_params,
                       category_one_assessments_without_exemptions: candidate_categories.cat1_without_exemptions,
                       category_two_assessments_without_exemptions: @category_two_assessments_without_exemptions).call
    end

    def candidate_categories
      @candidate_categories ||= DetermineCandidateCategories.new(goods_nomenclature)
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

    def resulting_category
      DetermineResultingCategory.new(
        candidate_categories.categories,
        check_your_answers_params[:c1ex],
        check_your_answers_params[:c2ex],
      ).call.to_s
    end
  end
end
