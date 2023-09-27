class FrontendMailer < ApplicationMailer
  default from: TradeTariffFrontend.from_email,
          to: TradeTariffFrontend.to_email

  def new_feedback(feedback)
    @message = feedback.message
    @name = feedback.name.presence
    @email = feedback.email.presence || TradeTariffFrontend.from_email

    mail subject: 'Trade Tariff Feedback',
         reply_to: @email
  end
end
