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
  delegate :regulation_url, to: :regulation

  def id
    "category_assessment_#{resource_id}"
  end

  def find(_id, _opts = {})
    raise NoMethodError, 'This method is not implemented'
  end

  def answered_exemptions(answers)
    applicable_answers = answers.dig(category.to_s, resource_id.to_s) || []

    exemptions.select do |exemption|
      applicable_answers.include?(exemption.code)
    end
  end
end
