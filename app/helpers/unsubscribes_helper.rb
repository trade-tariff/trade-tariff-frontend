module UnsubscribesHelper
  def unsubscribe_confirmation_content(subscription_type)
    if subscription_type == 'stop_press'
      {
        title: "You're unsubscribed from Stop Press watch list",
        header: 'You have unsubscribed',
        message: 'You will no longer receive any Stop Press emails from the UK Trade Tariff Service.',
      }
    else
      {
        title: "You're unsubscribed from commodity watch list",
        header: 'You have unsubscribed from your commodity watch list',
        message: 'You will no longer have access to your commodity watch list dashboard or receive email notifications.<br><br>If you have other UK Trade Tariff subscriptions, they will continue'.html_safe,
      }
    end
  end
end
