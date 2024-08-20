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

    validate :commodity_code_exists, if: -> { errors.empty? }

    def commodity_code_exists
      FetchGoodsNomenclature.new(commodity_code:, country_of_origin:, moving_date:).call
    rescue Faraday::ResourceNotFound
      errors.add(:base, 'This commodity code is not recognised.<br>Enter a different commodity code.'.html_safe)
    end
  end
end
