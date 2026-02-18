module EnquiryFormHelper
  FIELD_CONFIG = {
    'full_name' => 'text_field',
    'company_name' => 'text_field',
    'occupation' => 'text_field',
    'email_address' => 'text_field',
    'category' => 'radio_buttons',
    'query' => 'text_area',
  }.freeze

  def self.fields
    FIELD_CONFIG.keys
  end

  def partial_for_field(field)
    FIELD_CONFIG.fetch(field, 'unknown_field')
  end
end

def required_field?(field)
  !%w[company_name occupation].include?(field)
end

def error_message_for(field)
  {
    'full_name' => 'Please enter your full name.',
    'email_address' => 'Please enter your email address.',
    'query' => 'Please enter your query.',
    'category' => 'Please select a category.',
  }[field] || 'Please enter a value.'
end

def field_type(field)
  case field
  when 'query'
    :text_area
  when 'category'
    :radio_buttons
  else
    :text_field
  end
end

def field_label(field)
  {
    'company_name' => 'Company name (optional)',
    'occupation' => 'Job title (optional)',
    'category' => 'What do you need help with?',
    'query' => 'How can we help?',
  }[field] || field.humanize
end

def field_hint(field)
  {
    'email_address' => "We'll only use this to contact you about your enquiry.",
    'query' => "Explain what problem you're having and what help you need to resolve it.",
    'category' => 'Select one option.',
  }[field]
end

def radio_button_category_options
  [
    ['API & Dev Portal Support', 'api_dev_portal_support'],
    ['Classification (identify the correct commodity code)', 'classification'],
    ['Customs Valuation', 'customs_valuation'],
    ['Import Duties', 'import_duties'],
    ['Origin (Preferential and non-preferential)', 'origin'],
    ['Quotas', 'quotas'],
    ['Stop Press Subscription', 'stop_press_subscription'],
    ['Tariff Watch Lists (Private Beta)', 'tariff_watch_lists'],
  ]
end

def display_value_for(field, value)
  # for displaying the category label in the summary page.
  if field == 'category'
    match = radio_button_category_options.find { |_label, val| val == value }
    match ? match.first : value
  else
    value
  end
end

def field_value(field, session_data = session[:enquiry_data])
  if session_data[field].present?
    if field == 'query'
      Rails.cache.read(session_data[field])
    else
      session_data[field]
    end
  end
end

def validate_value(field, value)
  if value.blank? && required_field?(field)
    @alert = error_message_for(field)
  end
  if field == 'email_address' && !value.match?(URI::MailTo::EMAIL_REGEXP)
    @alert = 'Please enter a valid email address.'
  end

  max = 5000
  if field == 'query' && GovukFrontendHelper.utf16_code_units_length(value) > max
    @alert = "Please limit your query to #{max} characters or less."
  end
end
