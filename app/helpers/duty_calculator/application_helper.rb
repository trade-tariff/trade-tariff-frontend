module DutyCalculator
  module ApplicationHelper
    def govspeak(text)
      text = text['content'] || text[:content] if text.is_a?(Hash)
      return '' if text.nil?

      Govspeak::Document.new(text, sanitize: true).to_html.html_safe
    end
  end
end
