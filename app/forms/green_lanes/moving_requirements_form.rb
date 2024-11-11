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
    attr_reader :moving_date

    validates :commodity_code, length: { is: 10 },
                               format: { with: /\A\d+\z/, message: :only_numbers }
    validates :country_of_origin, presence: true
    validates :moving_date, presence: true
    validate :commodity_code_exists, if: -> { errors[:commodity_code].empty? }

    def moving_date=(date)
      date ||= {}
      @moving_date = valid_moving_date?(date) ? convert_to_date(date) : nil
    end

    private

    def commodity_code_exists
      ValidateDeclarableGoodsNomenclature.new(commodity_code:, moving_date:).call
    rescue Faraday::ResourceNotFound
      errors.add(:commodity_code, 'This commodity code is not recognised.<br>Enter a different commodity code.'.html_safe)
    end

    def valid_moving_date?(date)
      return false unless date[YEAR].to_s.length == 4
      return false unless [YEAR, MONTH, DAY].all? { |key| only_digits?(date[key]) }

      convert_to_date(date)
      true
    rescue ArgumentError, TypeError
      false
    end

    def only_digits?(str)
      str.to_s.match?(/^\d+$/)
    end

    def convert_to_date(date)
      Date.new(date[YEAR].to_i, date[MONTH].to_i, date[DAY].to_i)
    end
  end
end
