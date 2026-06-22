module EnquiryFormHelper
  IMPORT_DUTIES_AND_QUOTAS = 'import_duties_and_quota'.freeze

  FIELD_CONFIG = {
    'category' => 'category',
    'enquiry_type' => 'enquiry_type',
    'goods_details' => 'goods_details',
    'commodity_code' => 'commodity_code',
    'duty_details' => 'duty_details',
    'quota_details' => 'quota_details',
    'postal_or_baggage_details' => 'postal_or_baggage_details',
    'query' => 'query',
    'contact_details' => 'contact_details',
  }.freeze

  FIELD_PARAMS = {
    'category' => %w[category other_category],
    'enquiry_type' => %w[enquiry_type],
    'goods_details' => %w[goods_product goods_made_of goods_used_for goods_function goods_processed goods_packaged],
    'commodity_code' => %w[has_commodity_code commodity_code],
    'duty_details' => %w[duty_commodity_code customs_value country_of_origin destination query],
    'quota_details' => %w[
      quota_reference_type quota_commodity_code quota_order_number movement_reference_number country_of_origin
      destination query
    ],
    'postal_or_baggage_details' => %w[
      postal_or_baggage postal_commodity_code item purchase_price transport_cost query
    ],
    'query' => %w[query],
    'contact_details' => %w[email_address full_name company_name occupation],
  }.freeze

  RADIO_OPTIONS = {
    'enquiry_type' => [
      { label: 'Import duties', value: 'import_duties' },
      { label: 'Quotas', value: 'quotas' },
      { label: 'Item sent by post or in personal baggage', value: 'postal_or_baggage' },
    ],
    'destination' => [
      { label: 'England, Scotland or Wales', value: 'england_scotland_wales' },
      { label: 'Northern Ireland', value: 'northern_ireland' },
    ],
    'quota_reference_type' => [
      { label: 'Commodity code', value: 'commodity_code', conditional: ['conditional-quota-commodity-code', 'quota_commodity_code', 'Enter the commodity code'] },
      { label: 'Quota order number', value: 'quota_order_number', conditional: ['conditional-quota-order-number', 'quota_order_number', 'Enter the quota order number', 'Quota order numbers are usually 6 digits, for example 054010.'] },
      { label: 'Movement Reference Number (MRN)', value: 'movement_reference_number', conditional: ['conditional-movement-reference-number', 'movement_reference_number', 'Enter the MRN', 'An MRN is an 18-character alphanumeric code.'] },
      { label: 'No', value: 'no' },
    ],
    'postal_or_baggage' => [
      { label: 'Item sent by post', value: 'sent_by_post' },
      { label: 'Item brought in personal baggage', value: 'personal_baggage' },
    ],
  }.freeze

  def self.fields
    FIELD_CONFIG.keys
  end

  def self.permitted_fields
    FIELD_PARAMS.values.flatten
  end

  def partial_for_field(field)
    FIELD_CONFIG.fetch(field, 'unknown_field')
  end

  def field_label(field)
    {
      'category' => 'What do you need help with?',
      'enquiry_type' => 'What does your enquiry relate to?',
      'goods_details' => 'Tell us about your goods',
      'commodity_code' => 'Do you already have a possible commodity code?',
      'duty_details' => 'Tell us about your duty question',
      'quota_details' => 'Tell us about your quota question',
      'postal_or_baggage_details' => 'Tell us about your postal or baggage question',
      'query' => 'How can we help you?',
      'contact_details' => 'Contact details',
    }[field] || check_your_answers_label(field)
  end

  def category_options
    [
      {
        label: 'Classification',
        value: 'classification',
        hint: 'Help finding the correct commodity code for your goods.',
      },
      {
        label: 'Import duties and quotas',
        value: IMPORT_DUTIES_AND_QUOTAS,
        hint: 'Get information about duties and quotas.',
      },
      {
        label: 'Origin',
        value: 'origin',
        hint: 'Ask about preferential and non-preferential origin.',
      },
      {
        label: 'Valuation',
        value: 'valuation',
        hint: 'Help with determining the customs value of your goods.',
      },
      {
        label: 'API support and Developer Portal',
        value: 'developer_portal',
        hint: 'Get help on using the Trade Tariff APIs and the Developer Portal.',
      },
      {
        label: 'Stop Press and commodity code watch lists',
        value: 'stop_press_and_commodity_code_watch_lists',
        hint: 'Assistance with creating and managing watch lists.',
      },
      {
        label: 'Other',
        value: 'other',
        hint: 'Any other questions relating to the Online Trade Tariff.',
      },
    ]
  end

  def display_value_for(field, value)
    return category_label(value) if field == 'category'
    return 'Yes' if field == 'has_commodity_code' && value == 'yes'
    return 'No' if field == 'has_commodity_code' && value == 'no'
    return value == 'no' ? 'No' : 'Yes' if field == 'quota_reference_type' && radio_option_label(field, value)

    radio_option_label(field, value) || value
  end

  def field_value(field, data = @enquiry_data)
    data.to_h[field]
  end

  def field_error(field)
    @errors.to_a.find { |error| error[:field] == field }&.fetch(:message)
  end

  def field_error_class(field)
    'govuk-form-group--error' if field_error(field).present?
  end

  def category_label(value)
    category_options.find { |option| option[:value] == value }&.fetch(:label, value) || value
  end

  def radio_button_options(field)
    RADIO_OPTIONS.fetch(field, [])
  end

  def check_your_answers_row(step, fields, labelled_fields: fields)
    answers = check_your_answers_values(fields)
    return if answers.blank?

    {
      key: { text: check_your_answers_step_label(step) },
      value: { text: check_your_answers_value(answers, labelled_fields:) },
      actions: [
        {
          href: product_experience_enquiry_form_field_path(step, editing: true),
          visually_hidden_text: check_your_answers_step_label(step),
        },
      ],
    }
  end

  def check_your_answers_label(field)
    {
      'category' => 'What do you need help with?',
      'enquiry_type' => 'What does your enquiry relate to?',
      'query' => 'How can we help?',
      'duty_commodity_code' => 'Commodity code',
      'customs_value' => 'Customs value of the goods',
      'country_of_origin' => 'Country of origin',
      'destination' => 'Destination',
      'quota_reference_type' => 'Do you have a commodity code or quota order number?',
      'quota_commodity_code' => 'Commodity code',
      'quota_order_number' => 'Quota order number',
      'movement_reference_number' => 'Movement Reference Number (MRN)',
      'postal_or_baggage' => 'What are you asking about?',
      'postal_commodity_code' => 'Commodity code',
      'item' => 'What is the item?',
      'purchase_price' => 'Purchase price',
      'transport_cost' => 'Post, shipping, packaging or insurance costs',
      'goods_product' => 'What is the product?',
      'goods_made_of' => 'What is it made of?',
      'goods_used_for' => 'What is it used for?',
      'goods_function' => 'How does it work or function?',
      'goods_processed' => 'Has it been processed, prepared or treated in any way?',
      'goods_packaged' => 'How is it presented or packaged?',
      'has_commodity_code' => 'Do you already have a possible commodity code?',
      'commodity_code' => 'Possible commodity code',
      'email_address' => 'Email',
      'full_name' => 'Name',
      'company_name' => 'Company name',
      'occupation' => 'Role',
    }[field] || field.humanize
  end

  def check_your_answers_step_label(step)
    {
      'category' => 'What do you need help with?',
      'enquiry_type' => 'What does your enquiry relate to?',
      'goods_details' => 'Tell us about your goods',
      'commodity_code' => 'Do you already have a possible commodity code?',
      'duty_details' => 'Tell us about your duty question',
      'quota_details' => 'Tell us about your quota question',
      'postal_or_baggage_details' => 'Tell us about your postal or baggage question',
      'query' => 'How can we help?',
      'contact_details' => 'Contact details',
    }[step] || step.humanize
  end

  def check_your_answers_values(fields)
    fields.filter_map do |field|
      value = field_value(field)
      next if value.blank?

      [field, display_value_for(field, value)]
    end
  end

  def check_your_answers_value(answers, labelled_fields:)
    safe_join(
      answers.map do |field, value|
        if labelled_fields.include?(field)
          labelled_check_your_answers_value(field, value)
        else
          simple_format(value, { class: 'govuk-!-margin-bottom-0' })
        end
      end,
    )
  end

  def labelled_check_your_answers_value(field, value)
    tag.div(class: 'govuk-!-margin-bottom-3') do
      safe_join(
        [
          tag.p(tag.strong(check_your_answers_label(field)), class: 'govuk-!-font-weight-bold govuk-!-margin-bottom-0'),
          simple_format(value, { class: 'govuk-!-margin-bottom-0' }),
        ],
      )
    end
  end

  def radio_option_label(field, value)
    radio_button_options(field).find { |option| option[:value] == value }&.fetch(:label)
  end
end
