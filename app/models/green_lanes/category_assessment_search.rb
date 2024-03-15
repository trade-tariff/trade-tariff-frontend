require 'active_model'

class GreenLanes::CategoryAssessmentSearch
  include ActiveModel::Model

  attr_accessor   :commodity_code,
                  :country

  validates :commodity_code, presence: true, length: { minimum: 6, maximum: 10 }
end
