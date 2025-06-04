module DutyCalculator
  module Steps
    class Prefill < Steps::Base
      def next_step_path
        return duty_path if user_session.ni_to_gb_route? || user_session.eu_to_ni_route?

        return next_step_for_gb_to_ni if user_session.gb_to_ni_route?

        return next_step_for_row_to_gb if user_session.row_to_gb_route?

        next_step_for_row_to_ni
      end

      private

      def next_step_for_gb_to_ni
        return interstitial_path if user_session.trade_defence
        return duty_path if user_session.zero_mfn_duty

        trader_scheme_path
      end

      def next_step_for_row_to_ni
        return interstitial_path if user_session.trade_defence
        return trader_scheme_path unless user_session.zero_mfn_duty

        user_session.commodity_source = 'uk'

        customs_value_path
      end

      def next_step_for_row_to_gb
        customs_value_path
      end
    end
  end
end
