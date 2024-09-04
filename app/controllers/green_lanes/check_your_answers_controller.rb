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
      @category_two_assessments_without_exemptions = candidate_categories.cat2_without_exemptions
      @category_two_assessments = candidate_categories.cat2_with_exemptions
      @resulting_category = prettify_category(resulting_category)

      @answers = check_your_answers_params[:ans]
      @c1ex = check_your_answers_params[:c1ex]
      @c2ex = check_your_answers_params[:c2ex]
      @back_link_path = determine_back_link_path(check_your_answers_params)
    end

    private

    def determine_back_link_path(permitted_params)
      ans = permitted_params[:ans]
      category = if ans.nil?
                   1
                 elsif ans['2'].present?
                   2
                 else
                   1
                 end

      base_params = {
        commodity_code: permitted_params[:commodity_code],
        country_of_origin: permitted_params[:country_of_origin],
        moving_date: permitted_params[:moving_date],
      }

      back_link_params = if category == 2
                           base_params.merge(category:, ans:, c1ex: permitted_params[:c1ex], c2ex: permitted_params[:c2ex])
                         elsif ans.nil? || ans['1'].nil?
                           base_params
                         else
                           base_params.merge(category:, ans:, c1ex: permitted_params[:c1ex])
                         end

      green_lanes_applicable_exemptions_path(back_link_params)
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
