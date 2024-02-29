module GreenLanes
  class CategoryAssessmentsController < ApplicationController
    def index
      @category_assessments_search = CategoryAssessmentSearch.new
    end

    def search
      search_attributes = params.fetch(:search, params).permit(:commodity_code).to_h

      @category_assessments_search = CategoryAssessmentSearch.new(search_attributes)
    end

    def show
      # @category_assessments = ::GreenLanes::CategoryAssessment.all
    end
  end
end
