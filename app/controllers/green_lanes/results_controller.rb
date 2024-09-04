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
      @assessments = AssessmentsPresenter.new(candidate_categories, @answers)
      @cas_without_exemptions = cas_without_exemptions
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

    def cas_without_exemptions
      return [] if category == '3'

      candidate_categories.public_send("cat#{category}_without_exemptions")
    end

    def candidate_categories
      @candidate_categories ||= DetermineCandidateCategories.new(goods_nomenclature)
    end

    def goods_nomenclature
      @goods_nomenclature ||= GreenLanes::FetchGoodsNomenclature.new(results_params).call
    end

    def category
      return '3' if results_params[:category] == 'standard'

      results_params[:category]
    end

    def c1ex
      results_params[:c1ex]
    end

    def c2ex
      results_params[:c2ex]
    end
  end
end
