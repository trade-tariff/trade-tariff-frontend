module DutyCalculator
  # Shared wording for the VAT rate on Check your answers and on the results page.
  module VatSummaryHelper
    def import_destination_name(import_destination)
      Steps::ImportDestination::OPTIONS.find { |option| option.id == import_destination }&.name
    end

    def vat_rate_label(vat_code, fallback = nil)
      Steps::Vat::UX_LABELS.fetch(vat_code, fallback)
    end

    def vat_rate_summary(vat_code, assumed:, fallback: nil, bold: false, explanation_key: 'duty_calculator.vat.assumed_explanation')
      label = vat_rate_label(vat_code, fallback)
      label = tag.strong(label) if bold
      return label unless assumed

      safe_join([label, tag.br, I18n.t(explanation_key)])
    end
  end
end
