module DutyCalculator
  module Steps
    class CustomsValue < Steps::Base
      STEPS_TO_REMOVE_FROM_SESSION = %w[additional_code document_code excise].freeze

      attribute :monetary_value, :string
      attribute :shipping_cost, :string
      attribute :insurance_cost, :string

      validates :monetary_value, presence: true
      validates :monetary_value, numericality: { greater_than: 0 }
      validates :shipping_cost, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
      validates :insurance_cost, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

      def monetary_value
        super || user_session.monetary_value
      end

      def shipping_cost
        super || user_session.shipping_cost
      end

      def insurance_cost
        super || user_session.insurance_cost
      end

      def save!
        user_session.customs_value = {
          'monetary_value' => monetary_value,
          'shipping_cost' => shipping_cost,
          'insurance_cost' => insurance_cost,
        }
      end

      def next_step_path
        return measure_amount_path if applicable_measure_units.present?

        user_session.measure_amount = {}

        return additional_codes_path(applicable_measure_type_ids.first) if applicable_additional_codes?
        return document_codes_path(document_codes_applicable_measure_type_ids.first) if applicable_document_codes?
        return excise_path(applicable_excise_measure_type_ids.first) if applicable_excise_additional_codes?

        return vat_path if applicable_vat_options.keys.count > 1

        confirm_path
      end

      def previous_step_path
        return previous_step_for_gb_to_ni if user_session.gb_to_ni_route?
        return previous_step_for_row_to_ni if user_session.row_to_ni_route?

        country_of_origin_path
      end

      private

      def previous_step_for_gb_to_ni
        return meursing_additional_codes_path if applicable_meursing_codes?
        return interstitial_path if user_session.trade_defence || user_session.certificate_of_origin == 'no'

        certificate_of_origin_path
      end

      def previous_step_for_row_to_ni
        return country_of_origin_path if user_session.zero_mfn_duty

        return meursing_additional_codes_path if applicable_meursing_codes?
        return planned_processing_path if user_session.planned_processing.present?
        return annual_turnover_path if user_session.annual_turnover.present?
        return final_use_path if user_session.final_use == 'no'

        trader_scheme_path
      end
    end
  end
end
