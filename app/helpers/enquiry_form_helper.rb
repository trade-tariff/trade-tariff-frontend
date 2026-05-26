module EnquiryFormHelper
  FIELD_CONFIG = {
    'category' => 'category',
    'goods_details' => 'goods_details',
    'commodity_code' => 'commodity_code',
    'query' => 'query',
    'contact_details' => 'contact_details',
  }.freeze

  FIELD_PARAMS = {
    'category' => %w[category other_category],
    'goods_details' => %w[goods_product goods_made_of goods_used_for goods_function goods_processed goods_packaged],
    'commodity_code' => %w[has_commodity_code commodity_code],
    'query' => %w[query],
    'contact_details' => %w[email_address full_name company_name occupation],
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
      'goods_details' => 'Tell us about your goods',
      'commodity_code' => 'Do you already have a possible commodity code?',
      'query' => 'How can we help you?',
      'contact_details' => 'Contact details',
    }[field] || check_your_answers_label(field)
  end

  def category_options
    [
      {
        label: 'Classification',
        value: 'classification',
        hint: 'Help identifying the correct commodity code for your goods',
      },
      {
        label: 'Import Duties and Quota',
        value: 'import_duties_and_quota',
        hint: 'Help understanding the tariff related duties payable and quota queries',
      },
      {
        label: 'Origin',
        value: 'origin',
        hint: 'Help with free trade agreements and preferential, non-preferential and proof of origin',
      },
      {
        label: 'Valuation',
        value: 'valuation',
        hint: 'Help in understanding how to apply the six customs valuation methods for determining the customs value of your goods.',
      },
      {
        label: 'Developer Portal',
        value: 'developer_portal',
        hint: "Help with technical aspects of API's or the Developer Portal",
      },
      {
        label: 'Stop Press and Commodity Code watch lists',
        value: 'stop_press_and_commodity_code_watch_lists',
        hint: 'Help with creating or managing your subscriptions',
      },
      {
        label: 'Other',
        value: 'other',
        hint: 'Questions about the tariff or online tariff tool features that do not fit the options above',
      },
    ]
  end

  def display_value_for(field, value)
    return category_label(value) if field == 'category'
    return 'Yes' if field == 'has_commodity_code' && value == 'yes'
    return 'No' if field == 'has_commodity_code' && value == 'no'

    value
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

  def check_your_answers_rows(fields)
    fields.filter_map do |field|
      value = field_value(field)
      next if value.blank?

      {
        key: { text: check_your_answers_label(field) },
        value: { text: simple_format(display_value_for(field, value)) },
        actions: [{ href: change_link_for(field) }],
      }
    end
  end

  def check_your_answers_label(field)
    {
      'category' => 'What do you need help with?',
      'query' => 'How can we help?',
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

  def change_link_for(field)
    step = case field
           when 'category'
             'category'
           when 'query'
             'query'
           when 'goods_product', 'goods_made_of', 'goods_used_for', 'goods_function', 'goods_processed', 'goods_packaged'
             'goods_details'
           when 'has_commodity_code', 'commodity_code'
             'commodity_code'
           else
             'contact_details'
           end

    product_experience_enquiry_form_field_path(step, editing: true)
  end

  def text_too_long?(value, max)
    GovukFrontendHelper.utf16_code_units_length(value.to_s) > max
  end
end
