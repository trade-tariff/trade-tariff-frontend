require 'api_entity'

class GreenLanes::CategoryAssessment
  include XiOnlyApiEntity

  attr_accessor :category_assessment_id

  has_one :theme, class_name: 'GreenLanes::Theme'
  has_one :measure_type
  has_one :regulation, class_name: 'LegalAct'
  has_one :geographical_area
  has_many :excluded_geographical_areas, class_name: 'GeographicalArea'
  has_many :exemptions, polymorphic: {
    'exemption' => 'GreenLanes::Exemption',
    'certificate' => 'Certificate',
    'additional_code' => 'AdditionalCode',
  }

  delegate :category, to: :theme

  def id
    "category_assessment_#{category_assessment_id}"
  end

  def find(_id, _opts = {})
    raise NoMethodError, 'This method is not implemented'
  end

  delegate :regulation_url, to: :regulation
end
