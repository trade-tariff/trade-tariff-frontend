module GreenLanes
  class CategoryAssessmentsController < ApplicationController

    def index
      @category_assessments_search = CategoryAssessmentSearch.new
    end

    def search
      search_attributes = params.fetch(:search, params).permit(:commodity_code, :commit).to_h
      @category_assessments_search = CategoryAssessmentSearch.new(search_attributes)

      if @category_assessments_search.valid?
        @goods_nomenclature = GreenLanes::GoodsNomenclature.find(@category_assessments_search.commodity_code)
      else
        render :index
      end
    end

  end
end
