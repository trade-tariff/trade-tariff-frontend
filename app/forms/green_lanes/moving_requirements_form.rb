module GreenLanes
  class MovingRequirementsForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :commodity_code, :string
    attribute :country_of_origin, :string
    attribute :moving_date, :date

    validates :commodity_code, length: { is: 10 },
                               format: { with: /\A\d+\z/, message: :only_numbers }

    validates :country_of_origin, presence: true
    validates :moving_date, presence: true

    validate :commodity_code_exists

    def commodity_code_exists
      GreenLanes::GoodsNomenclature.find(
        commodity_code,
        {
          filter: { geographical_area_id: country_of_origin },
          as_of: moving_date,
        },
        { authorization: TradeTariffFrontend.green_lanes_api_token },
      )
    rescue Faraday::ResourceNotFound
      errors.add(:base, 'No result found for the given commodity code, country of origin and moving date.')
    end
  end
end
