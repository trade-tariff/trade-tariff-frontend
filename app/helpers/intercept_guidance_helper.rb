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
    govuk_markdown(linkified_code_references(govspeak(resolved)))
  end

private

  def linkified_code_references(html)
    GoodsNomenclatureCodeLinkifier.new(html).render
  end

  def govuk_markdown(html)
    fragment = Nokogiri::HTML::DocumentFragment.parse(html.to_s)
    fragment.css('[style]').each { |node| node.remove_attribute('style') }

    GOVUK_MARKDOWN_CLASSES.each do |selector, classes|
      fragment.css(selector).each { |node| append_classes(node, classes) }
    end

    fragment.to_html.html_safe
  end

  def append_classes(node, classes)
    node['class'] = (node['class'].to_s.split + classes).uniq.join(' ')
  end
end
