require 'api_entity'

class GreenLanes::CategoryAssessment
  include XiOnlyApiEntity

  has_one :theme, class_name: 'GreenLanes::Theme'
  has_one :measure_type
  has_one :regulation, class_name: 'LegalAct'
  has_one :geographical_area
  has_many :excluded_geographical_areas, class_name: 'GeographicalArea'
  has_many :exemptions, polymorphic: true

  delegate :category, to: :theme

  def find(_id, _opts = {})
    raise NoMethodError, 'This method is not implemented'
  end
end
