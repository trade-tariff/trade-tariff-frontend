module DutyCalculator
  module Steps
    class Vat < Steps::Base
      attribute :vat, :string

      validates :vat, presence: true

      def vat
        super || user_session.vat
      end

      def save!
        user_session.vat = vat
      end

      def vat_options
        applicable_vat_options.map do |k, v|
          OpenStruct.new(id: k, name: v)
        end
      end

      def next_step_path
        confirm_path
      end

      def previous_step_path
        return excise_path(user_session.excise_measure_type_ids.last) if user_session.excise_additional_code.present?
        return document_codes_path(user_session.document_code_measure_type_ids.last) if user_session.document_code_uk.present? || user_session.document_code_xi.present?
        return additional_codes_path(user_session.additional_code_measure_type_ids.last) if user_session.additional_code_uk.present? || user_session.additional_code_xi.present?
        return measure_amount_path unless user_session.measure_amount.empty?

        customs_value_path
      end
    end
  end
end
