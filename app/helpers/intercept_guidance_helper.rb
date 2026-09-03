module InterceptGuidanceHelper
  SUPPORTED_PLACEHOLDERS = {
    'request_id' => ->(search) { "**#{search.request_id}**" },
    'search_term' => ->(search) { search.q },
    'enquiries_email' => ->(_) { TradeTariffFrontend.enquiries_email },
    'webchat_url' => ->(_) { TradeTariffFrontend.webchat_url },
  }.freeze

  GOVUK_MARKDOWN_CLASSES = {
    'p' => %w[govuk-body],
    'a' => %w[govuk-link],
    'ul' => %w[govuk-list govuk-list--bullet],
    'ol' => %w[govuk-list govuk-list--number],
    'h2' => %w[govuk-heading-m],
    'h3' => %w[govuk-heading-s],
    'h4, h5, h6' => %w[govuk-heading-s],
  }.freeze

  def resolve_intercept_placeholders(message, search:)
    return message if message.blank? || search.blank?

    message.to_s.gsub(/\{\{(\w+)\}\}/) do |match|
      key = ::Regexp.last_match(1)
      resolver = SUPPORTED_PLACEHOLDERS[key]
      resolver ? resolver.call(search) : match
    end
  end

  def render_intercept_message(message, search:)
    resolved = resolve_intercept_placeholders(message, search:)
    govuk_markdown(govspeak(resolved))
  end

private

  def govuk_markdown(html)
    fragment = Nokogiri::HTML::DocumentFragment.parse(html.to_s)
    fragment.css('[style]').each { |node| node.remove_attribute('style') }

    GOVUK_MARKDOWN_CLASSES.each do |selector, classes|
      fragment.css(selector).each { |node| append_classes(node, classes) }
    end
    fragment.css('a').each { |node| apply_new_tab_standard(node) }
    replace_classification_support_link(fragment)

    fragment.to_html.html_safe
  end

  def append_classes(node, classes)
    node['class'] = (node['class'].to_s.split + classes).uniq.join(' ')
  end

  def apply_new_tab_standard(node)
    node['target'] = '_blank'
    node['rel'] = (node['rel'].to_s.split + %w[noopener noreferrer]).uniq.join(' ')
  end

  def replace_classification_support_link(fragment)
    email_link = fragment.css('a[href]').find do |link|
      link['href'].casecmp?("mailto:#{TradeTariffFrontend.enquiries_email}")
    end
    return if email_link.blank?

    promote_support_label(email_link.ancestors('p').first, from: 'Email:', to: 'Enquiry form')

    webchat_paragraph = fragment.css('p').find do |paragraph|
      paragraph.at_css('strong')&.text&.strip == 'Webchat:'
    end
    promote_support_label(webchat_paragraph, from: 'Webchat:', to: 'Webchat')

    email_link.content = 'Ask a classification question'
    email_link['href'] = product_experience_enquiry_form_path
    email_link.remove_attribute('target')
    email_link.remove_attribute('rel')
  end

  def promote_support_label(paragraph, from:, to:)
    label = paragraph&.at_css('strong')
    return unless label&.text&.strip == from

    heading = Nokogiri::XML::Node.new('h3', paragraph.document)
    heading.content = to
    heading['class'] = GOVUK_MARKDOWN_CLASSES.fetch('h3').join(' ')
    paragraph.add_previous_sibling(heading)
    label.remove
  end
end
