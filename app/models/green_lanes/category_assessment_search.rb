require 'active_model'

class GreenLanes::CategoryAssessmentSearch
  include ActiveModel::Model

  attr_accessor   :commodity_code,
                  :commit

  validates :commodity_code, presence: true, length: { minimum: 4, maximum: 10 }

  def initialize(...)
    super
  end
end
