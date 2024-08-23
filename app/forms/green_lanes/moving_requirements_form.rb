module GreenLanes
  YEAR = 1
  MONTH = 2
  DAY = 3

  class MovingRequirementsForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :commodity_code, :string
    attribute :country_of_origin, :string

    def moving_date=(date)
      date ||= {}

      @moving_date = if valid_moving_date?(date)
                       Date.new(date[YEAR], date[MONTH], date[DAY])
                     end
    end

    attr_reader :moving_date

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

    private

    def valid_moving_date?(date)
      Date.new(date[YEAR], date[MONTH], date[DAY])

      raise ArgumentError unless date[YEAR].to_s.length == 4

      true
    rescue ArgumentError, TypeError
      false
    end
  end
end
