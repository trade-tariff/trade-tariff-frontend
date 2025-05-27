module DutyCalculator
  module Steps
    class FinalUse < Steps::Base
      include RoutesHelper

      STEPS_TO_REMOVE_FROM_SESSION = %w[
        certificate_of_origin
        annual_turnover
        planned_processing
        document_code
        excise
      ].freeze

      attribute :final_use, :string

      validates :final_use, presence: true

      def final_use
        super || user_session.final_use
      end

      def save!
        user_session.final_use = final_use
      end

      def next_step_path
        return annual_turnover_path if user_session.final_use == 'yes'
        return certificate_of_origin_path if user_session.gb_to_ni_route?

        interstitial_path
      end

      def previous_step_path
        trader_scheme_path
      end

      def options
        [
          OpenStruct.new(id: 'yes', name: I18n.t("final_use.#{current_route}.yes_option")),
          OpenStruct.new(id: 'no', name: I18n.t("final_use.#{current_route}.no_option")),
        ]
      end

      def heading
        I18n.t("final_use.#{current_route}.heading")
      end
    end
  end
end
