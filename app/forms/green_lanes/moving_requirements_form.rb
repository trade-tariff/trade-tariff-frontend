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

    def moving_date=(date)
      date ||= {}
      @moving_date = valid_moving_date?(date) ? convert_to_date(date) : nil
    end

    validates :commodity_code, length: { is: 10 },
                               format: { with: /\A\d+\z/, message: :only_numbers }

    validates :country_of_origin, presence: true
    validates :moving_date, presence: true

    validate :commodity_code_exists, if: -> { errors[:commodity_code].empty? }

    def commodity_code_exists
      fetch_goods_nomenclature
    rescue Faraday::ResourceNotFound
      errors.add(:commodity_code, 'This commodity code is not recognised.<br>Enter a different commodity code.'.html_safe)
    end

    private

    def fetch_goods_nomenclature
      FetchGoodsNomenclature.new(
        commodity_code:,
        country_of_origin:,
        moving_date:,
      ).call
    end

    def valid_moving_date?(date)
      return false unless date[YEAR].to_s.length == 4

      only_digits?(date[YEAR]) && only_digits?(date[MONTH]) && only_digits?(date[DAY])
    rescue ArgumentError, TypeError
      false
    end

    def only_digits?(str)
      /^\d+$/.match?(str)
    end

    def convert_to_date(date)
      Date.new(date[YEAR].to_i, date[MONTH].to_i, date[DAY].to_i)
    end
  end
end
