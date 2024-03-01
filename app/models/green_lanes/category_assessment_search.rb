require 'api_entity'

class GreenLanes::CategoryAssessmentSearch
  include ApiEntity

  COMMODITY_CODE = /\A[0-9]{10}\z/
  HEADING_CODE = /\A[0-9]{4}\z/

  attr_accessor   :commodity_code

  def initialize(attributes = {})
    super
  end
end
