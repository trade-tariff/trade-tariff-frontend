module GreenLanes
  class CategoryAssessmentsController < ApplicationController

    def search
      search_attributes = params.fetch(:search, params).permit(:commodity_code, :commit).to_h
      @category_assessments_search = CategoryAssessmentSearch.new(search_attributes)

      @goods_nomenclature = GreenLanes::GoodsNomenclature.find(@category_assessments_search.commodity_code)
    end

  end
end
