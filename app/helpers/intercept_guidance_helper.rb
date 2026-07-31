module InterceptGuidanceHelper
  SUPPORTED_PLACEHOLDERS = {
    'request_id' => ->(search) { "**#{search.request_id}**" },
    'search_term' => ->(search) { search.q },
    'enquiries_email' => ->(_) { TradeTariffFrontend.enquiries_email },
    'webchat_url' => ->(_) { TradeTariffFrontend.webchat_url },
  }.freeze

  # Legacy destinations for the generic intercept "help on using the tariff" link.
  # Prefer {{help_url}} in new template copy; keep these rewrites for already-published intercepts.
  LEGACY_HELP_URLS = [
    'https://www.gov.uk/guidance/classification-of-goods/',
    'https://www.gov.uk/guidance/classification-of-goods',
    '/help/help_find_commodity',
  ].freeze

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
      case key
      when 'help_url'
        help_path
      else
        resolver = SUPPORTED_PLACEHOLDERS[key]
        resolver ? resolver.call(search) : match
      end
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
    fragment.css('a').each do |node|
      normalize_legacy_help_link(node)
      apply_new_tab_standard(node)
    end

    fragment.to_html.html_safe
  end

  def append_classes(node, classes)
    node['class'] = (node['class'].to_s.split + classes).uniq.join(' ')
  end

  def normalize_legacy_help_link(node)
    href = node['href'].to_s
    return unless LEGACY_HELP_URLS.include?(href) || href.end_with?('/help/help_find_commodity')

    node['href'] = help_path
  end

  def apply_new_tab_standard(node)
    node['target'] = '_blank'
    node['rel'] = (node['rel'].to_s.split + %w[noopener noreferrer]).uniq.join(' ')
  end
end
