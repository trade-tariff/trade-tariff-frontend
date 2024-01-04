# rubocop:disable Rails/ApplicationMailer
class FrontendMailer < ActionMailer::Base
  # rubocop:enable Rails/ApplicationMailer
  default from: TradeTariffFrontend.from_email,
          to: TradeTariffFrontend.to_email

  def new_feedback(feedback)
    @message = feedback.message

    mail subject: 'Trade Tariff Feedback'
  end
end
