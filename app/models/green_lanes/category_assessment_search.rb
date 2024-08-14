require 'active_model'

class GreenLanes::CategoryAssessmentSearch
  include ActiveModel::Model

  attr_accessor :commodity_code,
                :country

  validates :commodity_code, presence: true,
                             length: { minimum: 10, maximum: 10, message: 'Enter a declarable 10 digit commodity code.' }

  def self.country_options
    TradeTariffFrontend::ServiceChooser.with_source(:xi) do
      GeographicalArea.all.sort_by(&:long_description)
    end
  end
end
