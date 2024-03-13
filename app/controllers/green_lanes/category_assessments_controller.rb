module GreenLanes
  class CategoryAssessmentsController < ApplicationController
    before_action :disable_search_form,
                  :check_allowed

    def show
      @category_assessments_search = CategoryAssessmentSearch.new
    end

    def create
      @category_assessments_search = CategoryAssessmentSearch.new(ca_search_params)

      if @category_assessments_search.valid?
        @goods_nomenclature = GreenLanes::GoodsNomenclature.find(
          @category_assessments_search.commodity_code,
          filter: { geographical_area_id: @category_assessments_search.country },
        )
      else
        render :show
      end
    end

    private

    def ca_search_params
      params.require(:green_lanes_category_assessment_search).permit(:commodity_code, :country)
    end

    def check_allowed
      raise TradeTariffFrontend::FeatureUnavailable unless TradeTariffFrontend.green_lane_allowed?
    end
  end
end
