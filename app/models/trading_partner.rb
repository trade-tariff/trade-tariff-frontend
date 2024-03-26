class TradingPartner
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :country, :string

  delegate :options, to: :class

  validate :validate_country

  def validate_country
    country.in?(options.map(&:id)).tap do |valid_country|
      errors.add(:country, :invalid_country) unless valid_country
    end
  end

  def self.options
    GeographicalArea.all.map do |geographical_area|
      OpenStruct.new(
        name: geographical_area.long_description,
        id: geographical_area.id,
      )
    end
  end
end
