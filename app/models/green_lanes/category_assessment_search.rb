require 'active_model'

class GreenLanes::CategoryAssessmentSearch
  include ActiveModel::Model

  attr_accessor   :commodity_code,
                  :country

  validates :commodity_code, presence: true,
                             length: { minimum: 10, maximum: 10, message: 'Enter a declarable 10 digit commodity code.' }

  def self.country_options
    GeographicalArea.all.sort_by(&:long_description).map do |geographical_area|
      OpenStruct.new(
        name: geographical_area.long_description,
        id: geographical_area.id,
      )
    end
  end
end
