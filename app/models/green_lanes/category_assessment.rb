require 'api_entity'

class GreenLanes::CategoryAssessment
  include ApiEntity

  attr_accessor :category,
                :theme

  has_one :geographical_area
  has_many :excluded_geographical_areas, class_name: 'GeographicalArea'
  has_many :exemptions, polymorphic: true

  def find(id, opts = {})
    raise NotImplementedError, 'This method is not implemented'
  end
end
