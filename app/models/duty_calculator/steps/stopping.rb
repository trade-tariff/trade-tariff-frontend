module DutyCalculator
  module Steps
    class Stopping < Steps::Base
      def previous_step_path
        return document_codes_path(previous_measure_type_id) if stopping_document_codes?

        import_date_path(commodity_code: user_session.commodity_code)
      end

      private

      def stopping_document_codes?
        user_session.document_code? && previous_measure_type_id.present?
      end

      def previous_measure_type_id
        @previous_measure_type_id ||= filtered_commodity
          .stopping_measures
          .select(&:stopping_condition_met?)
          .first&.measure_type&.id
      end
    end
  end
end
