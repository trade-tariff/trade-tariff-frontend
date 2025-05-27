module DutyCalculator
  module Steps
    class Excise < Steps::Base
      DISABLED_ADDITIONAL_CODES = %w[440 441].freeze

      attribute :measure_type_id, :string
      attribute :additional_code, :string

      validates :measure_type_id, presence: true
      validates :additional_code, presence: true

      def additional_code
        super || user_session.excise_additional_code[measure_type_id]
      end

      def save!
        user_session.excise_additional_code = { measure_type_id => additional_code }
      end

      def options
        available_additional_codes.map do |additional_code|
          code = additional_code['code'].sub('X', '')
          overlay = "#{additional_code['overlay']} (X#{code})".html_safe

          OpenStruct.new(
            id: code,
            name: overlay,
            disabled: code.in?(DISABLED_ADDITIONAL_CODES),
          )
        end
      end

      def small_brewers_relief?
        options.any?(&:disabled)
      end

      def measure_type_description
        applicable_excise_additional_codes.dig(measure_type_id, 'measure_type_description').downcase
      end

      def next_step_path
        return excise_path(next_measure_type_id) if next_measure_type_id.present?
        return vat_path if applicable_vat_options.keys.count > 1

        confirm_path
      end

      def previous_step_path
        return excise_path(previous_measure_type_id) if previous_measure_type_id.present?
        return document_codes_path(user_session.document_code_measure_type_ids.last) if user_session.document_code_uk.present? || user_session.document_code_xi.present?
        return additional_codes_path(applicable_measure_type_ids.first) if applicable_additional_codes?

        return measure_amount_path if applicable_measure_units.present?

        customs_value_path
      end

      private

      def available_additional_codes
        return {} unless applicable_excise_additional_codes?

        applicable_excise_additional_codes[measure_type_id]['additional_codes']
      end

      def next_measure_type_id
        return nil if next_measure_type_index > applicable_excise_measure_type_ids.size - 1

        applicable_excise_measure_type_ids[next_measure_type_index]
      end

      def previous_measure_type_id; end

      def next_measure_type_index
        @next_measure_type_index ||= applicable_excise_measure_type_ids.find_index(measure_type_id) + 1
      end

      def previous_measure_type_index
        @previous_measure_type_index ||= applicable_excise_measure_type_ids.find_index(measure_type_id) - 1
      end
    end
  end
end
