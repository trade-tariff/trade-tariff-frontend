# rubocop:disable Rails/ApplicationMailer
class FrontendMailer < ActionMailer::Base
  # rubocop:enable Rails/ApplicationMailer
  default from: TradeTariffFrontend.from_email,
          to: TradeTariffFrontend.to_email,
          bcc: TradeTariffFrontend.support_email

  def new_feedback(feedback)
    @message = feedback.message
    @url = feedback.referrer
    @page_useful = feedback.page_useful

    mail subject: 'Trade Tariff Feedback'
  end
end
