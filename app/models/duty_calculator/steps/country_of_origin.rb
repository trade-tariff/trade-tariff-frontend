module DutyCalculator
  module Steps
    class CountryOfOrigin < Steps::Base
      STEPS_TO_REMOVE_FROM_SESSION = %w[
        trader_scheme
        final_use
        certificate_of_origin
        annual_turnover
        planned_processing
        document_code
        excise
      ].freeze

      attr_reader :zero_mfn_duty, :trade_defence

      attribute :country_of_origin, :string
      attribute :other_country_of_origin, :string

      validates :country_of_origin, presence: true
      validate :other_country_of_origin_presence, if: :other_country_of_origin?

      def initialize(attributes = {}, opts = {})
        super(attributes)

        @zero_mfn_duty = opts[:zero_mfn_duty]
        @trade_defence = opts[:trade_defence]
      end

      def country_of_origin
        super || user_session.country_of_origin
      end

      def save!
        user_session.country_of_origin = country_of_origin
        user_session.other_country_of_origin = other_country_of_origin
        user_session.trade_defence = trade_defence
        user_session.zero_mfn_duty = zero_mfn_duty
      end

      def self.options_for(service, include_eu_members: true)
        return Api::GeographicalArea.non_eu_countries unless include_eu_members

        Api::GeographicalArea.list_countries(service.to_sym)
      end

      def next_step_path
        return duty_path if user_session.ni_to_gb_route? || user_session.eu_to_ni_route?

        return next_step_for_gb_to_ni if user_session.gb_to_ni_route?

        return next_step_for_row_to_gb if user_session.row_to_gb_route?

        next_step_for_row_to_ni
      end

      def previous_step_path
        import_destination_path
      end

      private

      def other_country_of_origin_presence
        return if other_country_of_origin.present?

        errors.add(:country_of_origin, :blank)
      end

      def other_country_of_origin?
        country_of_origin == 'OTHER'
      end

      def next_step_for_gb_to_ni
        return interstitial_path if trade_defence
        return duty_path if zero_mfn_duty

        trader_scheme_path
      end

      def next_step_for_row_to_ni
        return interstitial_path if trade_defence
        return trader_scheme_path unless zero_mfn_duty

        user_session.commodity_source = 'uk'

        customs_value_path
      end

      def next_step_for_row_to_gb
        customs_value_path
      end
    end
  end
end
