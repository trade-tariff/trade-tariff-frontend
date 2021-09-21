module StepsHelper
  def back_link
    link_to 'Back', meursing_lookup_step_path(wizard.previous_key), class: 'govuk-back-link' if wizard.previous_key
  end

  def last_commodity_code
    session[:commodity_code]
  end
end
