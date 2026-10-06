module DutyCalculator
  module Steps
    class Vat < Steps::Base
      DONT_KNOW = 'dont_know'.freeze
      STANDARD_RATE = 'VAT'.freeze

      UX_LABELS = {
        'VATZ' => 'Zero-rate VAT (0%)',
        'VATR' => 'Reduced rate VAT (5%)',
        'VAT' => 'Standard rate VAT (20%)',
        'VATE' => 'VAT exempt',
      }.freeze

      attribute :vat, :string

      validates :vat, presence: true

      def vat
        super || (assumed? ? DONT_KNOW : user_session.vat)
      end

      def save!
        user_session.vat_assumed = dont_know? if ux_improvements?
        user_session.vat = dont_know? ? STANDARD_RATE : vat
      end

      def vat_options
        return ux_vat_options if ux_improvements?

        applicable_vat_options.map do |k, v|
          Option.new(id: k, name: v)
        end
      end

      def dont_know?
        ux_improvements? && vat == DONT_KNOW
      end

      def assumed?
        ux_improvements? && user_session.vat_assumed && user_session.vat.present?
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

    private

      def ux_vat_options
        options = applicable_vat_options.map do |k, v|
          Option.new(id: k, name: UX_LABELS.fetch(k, v))
        end

        options << Option.new(id: DONT_KNOW, name: "I don't know")
      end
    end
  end
end
