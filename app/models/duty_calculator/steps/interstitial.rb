module DutyCalculator
  module Steps
    class Interstitial < Steps::Base
      STEPS_TO_REMOVE_FROM_SESSION = %w[meursing_additional_code].freeze

      def next_step_path
        return meursing_additional_codes_path if user_session.meursing_route? && applicable_meursing_codes?

        customs_value_path
      end

      def previous_step_path
        return previous_step_for_gb_to_ni if user_session.gb_to_ni_route?

        previous_step_for_row_to_ni
      end

      private

      def previous_step_for_gb_to_ni
        return certificate_of_origin_path if user_session.certificate_of_origin == 'no'

        country_of_origin_path
      end

      def previous_step_for_row_to_ni
        return country_of_origin_path if user_session.trade_defence?
        return trader_scheme_path if user_session.trader_scheme == 'no'
        return final_use_path if user_session.final_use == 'no'

        planned_processing_path if user_session.unacceptable_processing?
      end
    end
  end
end
