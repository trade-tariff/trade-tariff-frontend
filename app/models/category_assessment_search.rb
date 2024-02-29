require 'api_entity'

class CategoryAssessmentSearch
  include ApiEntity

  COMMODITY_CODE = /\A[0-9]{10}\z/
  HEADING_CODE = /\A[0-9]{4}\z/

  attr_reader   :commodity_code      # search text query

  def initialize(attributes = {})
    super
  end
end
