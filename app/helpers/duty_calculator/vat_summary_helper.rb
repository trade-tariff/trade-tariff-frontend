module DutyCalculator
  # Shared wording for the VAT rate on Check your answers and on the results page.
  module VatSummaryHelper
    def vat_rate_label(vat_code, fallback = nil)
      Steps::Vat::UX_LABELS.fetch(vat_code, fallback)
    end

    def vat_rate_summary(vat_code, assumed:, fallback: nil, bold: false)
      label = vat_rate_label(vat_code, fallback)
      label = tag.strong(label) if bold
      return label unless assumed

      safe_join([label, tag.br, I18n.t('duty_calculator.vat.assumed_explanation')])
    end
  end
end
