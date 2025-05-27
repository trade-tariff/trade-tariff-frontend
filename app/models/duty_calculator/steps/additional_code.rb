module DutyCalculator
  module Steps
    class AdditionalCode < Steps::Base
      STEPS_TO_REMOVE_FROM_SESSION = %w[document_code excise].freeze

      attribute :measure_type_id, :string
      attribute :additional_code_uk, :string
      attribute :additional_code_xi, :string

      validates :measure_type_id, presence: true
      validates :additional_code_uk, presence: true, if: -> { applicable_for?(source: 'uk') }
      validates :additional_code_xi, presence: true, if: -> { applicable_for?(source: 'xi') }

      def additional_code_uk
        super || user_session.additional_code_uk[measure_type_id]
      end

      def additional_code_xi
        super || user_session.additional_code_xi[measure_type_id]
      end

      def save!
        user_session.additional_code_uk = { measure_type_id => additional_code_uk }
        user_session.additional_code_xi = { measure_type_id => additional_code_xi }
      end

      def options_for_select_for(source:)
        available_additional_codes_for(source:).map { |ac| build_option(ac['code'], ac['overlay']) }
      end

      def measure_type_description_for(source:)
        applicable_additional_codes[source][measure_type_id]['measure_type_description'].downcase
      end

      def next_step_path
        return additional_codes_path(next_measure_type_id) if next_measure_type_id.present?
        return document_codes_path(first_measure_type_id_for_document_codes) if first_measure_type_id_for_document_codes.present?
        return excise_path(applicable_excise_measure_type_ids.first) if applicable_excise_additional_codes?
        return vat_path if applicable_vat_options.keys.count > 1

        confirm_path
      end

      def previous_step_path
        return additional_codes_path(previous_measure_type_id) if previous_measure_type_id.present?

        return measure_amount_path if applicable_measure_units.present?

        customs_value_path
      end

      private

      def available_additional_codes_for(source:)
        return {} if applicable_additional_codes[source][measure_type_id].blank?

        applicable_additional_codes[source][measure_type_id]['additional_codes']
      end

      def build_option(code, overlay)
        OpenStruct.new(
          id: code,
          name: "#{code} - #{overlay}".html_safe,
        )
      end

      def first_measure_type_id_for_document_codes
        document_codes_applicable_measure_type_ids.first
      end

      def next_measure_type_id
        return nil if next_measure_type_index > applicable_measure_type_ids.size - 1

        applicable_measure_type_ids[next_measure_type_index]
      end

      def previous_measure_type_id
        return nil if previous_measure_type_index.negative?

        applicable_measure_type_ids[previous_measure_type_index]
      end

      def next_measure_type_index
        @next_measure_type_index ||= applicable_measure_type_ids.find_index(measure_type_id) + 1
      end

      def previous_measure_type_index
        @previous_measure_type_index ||= applicable_measure_type_ids.find_index(measure_type_id) - 1
      end

      def applicable_for?(source:)
        return applicable_additional_codes[source][measure_type_id].present? if user_session.deltas_applicable?

        user_session.commodity_source == source
      end
    end
  end
end
