module DutyCalculator
  module Api
    class BaseComponent < Api::Base
      CONJUNCTION_OPERATORS = %w[MAX MIN].freeze
      MATHEMATICAL_OPERATORS = %w[+ -].freeze

      ALCOHOL_UNIT = 'ASV'.freeze
      DECITONNE_UNIT = 'DTN'.freeze
      LITERS_PURE_ALCOHOL_UNIT = 'LPA'.freeze
      HECTOLITERS_UNIT = 'HLT'.freeze
      RETAIL_PRICE_UNIT = 'RET'.freeze
      SPR_DISCOUNT_UNIT = 'SPR'.freeze
      SUCROSE_UNIT = 'BRX'.freeze
      VOLUME_UNIT = 'HLT'.freeze

      attributes :id,
                 :duty_expression_id,
                 :duty_amount,
                 :duty_expression_description,
                 :duty_expression_abbreviation,
                 :monetary_unit_code,
                 :monetary_unit_abbreviation,
                 :measurement_unit_code,
                 :measurement_unit_qualifier_code

      enum :measurement_unit_code, {
        retail_price: %w[RET],
      }

      enum :monetary_unit_code, {
        euros: %w[EUR],
        pounds: %w[GBP],
      }

      enum :duty_expression_id, {
        amount_or_percentage: %w[01 04 19 20],
      }

      enum :unit, {
        alcohol_volume: %w[ASVX],
        sucrose: %w[DTNZ],
        spq: %w[SPQ],
      }

      def ad_valorem?
        no_specific_duty?
      end

      def specific_duty?
        measurement_unit_code
      end

      def no_specific_duty?
        !specific_duty?
      end

      def unit
        return nil if measurement_unit_code.blank?

        "#{measurement_unit_code}#{measurement_unit_qualifier_code}"
      end

      def conjunction_operator?
        duty_expression_abbreviation.in?(CONJUNCTION_OPERATORS)
      end

      def operator
        duty_expression_abbreviation
      end
    end
  end
end
