module DutyCalculator
  module ExciseHelper
    def excise_hint
      t('excise_page.hint_html', excise_link:)
    end

  private

    def excise_link
      link_to(
        t('excise_page.link_text'),
        'https://www.gov.uk/government/publications/uk-trade-tariff-excise-duties-reliefs-drawbacks-and-allowances/uk-trade-tariff-excise-duties-reliefs-drawbacks-and-allowances',
        class: 'govuk-link',
        target: '_blank',
        rel: 'noopener norefferer',
      )
    end
  end
end
