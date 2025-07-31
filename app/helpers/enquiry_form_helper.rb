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

  def enquiry_form_page_title(title = nil, error: false)
    default = 'UK Online Trade Tariff'
    base_title = "#{title} | #{default}"

    if error
      base_title = "Error: #{base_title}"
    end

    if title
      content_for :title, base_title
    else
      content_for(:title) || default
    end
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

def category_options
  [
    ['Classification (identify the correct commodity code)', 'classification'],
    ['Customs Valuation', 'customs_valuation'],
    ['Import Duties', 'import_duties'],
    ['Origin (Preferential and non-preferential)', 'origin'],
    ['Quotas', 'quotas'],
    ['Tariff Preferences', 'preferences'],
    ['Stop Press Subscription', 'stop_press_subscription'],
    ['Other', 'other'],
  ]
end

def display_value_for(field, value)
  # for displaying the category label in the summary page.
  if field == 'category'
    match = category_options.find { |_label, val| val == value }
    match ? match.first : value
  else
    value
  end
end

def field_value(field)
  session[:enquiry_data][field]
end
