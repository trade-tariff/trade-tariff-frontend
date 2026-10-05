module DutyCalculator
  module Steps
    class Stopping < Steps::Base
      def previous_step_path
        return document_codes_path(previous_measure_type_id) if stopping_document_codes?

        import_date_step_path
      end

      private

      def stopping_document_codes?
        user_session.document_code? && previous_measure_type_id.present?
      end

      # Send the user back to the answer that caused the stop. Fall back to the hard stop,
      # then the last rejected duty option, if the stop page is opened directly.
      def previous_measure_type_id
        @previous_measure_type_id ||= stored_stopping_measure_type_id || begin
          met = filtered_commodity.stopping_measures.select(&:stopping_condition_met?)

          (met.find(&:hard_stopping_condition_met?) || met.last)&.measure_type&.id
        end
      end

      # Ignore a value left over from another journey
      def stored_stopping_measure_type_id
        stored = user_session.stopping_measure_type_id.presence

        stored if stored.in?(document_codes_applicable_measure_type_ids)
      end
    end
  end
end
