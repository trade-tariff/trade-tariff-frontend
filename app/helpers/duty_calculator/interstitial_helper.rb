module DutyCalculator
  module InterstitialHelper
    def interstitial_partial_options
      {
        partial: 'duty_calculator/steps/interstitial/shared/context',
        locals: partial_locals,
      }
    end

  private

    def partial_locals
      if user_session.gb_to_ni_route?
        gb_to_ni_partial_locals
      elsif user_session.row_to_ni_route?
        row_to_ni_partial_locals
      else
        fallback_partial_locals
      end
    end

    def gb_to_ni_partial_locals
      if user_session.trade_defence?
        { heading: t('interstitial.gb_to_ni.trade_defence.heading'), body: t('interstitial.gb_to_ni.trade_defence.body') }
      else
        { heading: t('interstitial.gb_to_ni.certificate_of_origin.heading'), body: t('interstitial.gb_to_ni.certificate_of_origin.body') }
      end
    end

    def row_to_ni_partial_locals
      if user_session.trade_defence?
        {
          heading: t('interstitial.row_to_ni.trade_defence.heading'),
          body: t('interstitial.row_to_ni.trade_defence.body'),
        }
      elsif user_session.trader_scheme == 'no'
        {
          heading: t('interstitial.row_to_ni.trader_scheme.heading'),
          body: t('interstitial.row_to_ni.trader_scheme.body_html', market_scheme_type:),
        }
      elsif user_session.final_use == 'no'
        {
          heading: t('interstitial.row_to_ni.final_use.heading'),
          body: t('interstitial.row_to_ni.final_use.body'),
        }
      elsif user_session.unacceptable_processing?
        {
          heading: t('interstitial.row_to_ni.commercial_purposes.heading'),
          body: t('interstitial.row_to_ni.commercial_purposes.body'),
        }
      end
    end

    def fallback_partial_locals
      {
        heading: t('interstitial.fallback.heading'),
        body: t('interstitial.fallback.body', link: feedback_link).html_safe,
      }
    end

    def feedback_link
      link_to('here', feedback_url, class: 'govuk-link', target: '_blank', rel: 'noopener')
    end

    def user_session
      UserSession.get
    end
  end
end
