module StepsHelper
  NO_FORM_STEPS = %w[
    start
    end
  ].freeze

  def step_with_form?(step)
    !step.key.in?(NO_FORM_STEPS)
  end

  def page_title_for(step)
    "Meursing lookup: #{step.key}"
  end

  def back_link
    link_to 'Back', meursing_lookup_step_path(wizard.previous_key), class: 'govuk-back-link' if wizard.previous_key
  end

  def last_commodity_code
    session[:commodity_code]
  end
end
