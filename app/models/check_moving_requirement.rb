class CheckMovingRequirement
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :commodity_code, :string
  attribute :country_of_origin, :string

  attribute :day, :integer
  attribute :month, :integer
  attribute :years, :integer

  def validate_commodity_code
    if commodity_code.lenght != 10
      errors.add(:commodity_code, :invalid_commodity_code, message: "Commodity code must have 10 digits")
    end
  end
end
