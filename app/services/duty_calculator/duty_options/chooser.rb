module DutyCalculator
  module DutyOptions
    class Chooser
      attr_reader :uk_duty_option, :xi_duty_option, :customs_value

      def initialize(uk_duty_option, xi_duty_option, customs_value)
        @uk_duty_option = uk_duty_option
        @xi_duty_option = xi_duty_option
        @customs_value = customs_value
      end

      def call
        return uk_duty_option if delta <= three_pct_val

        xi_duty_option
      end

      private

      def three_pct_val
        @three_pct_val ||= (customs_value * 3 / 100.0).round(2)
      end

      def delta
        @delta ||= (xi_duty_option.value - uk_duty_option.value).abs
      end
    end
  end
end
