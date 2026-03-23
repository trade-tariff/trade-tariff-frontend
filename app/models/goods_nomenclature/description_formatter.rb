class GoodsNomenclature
  class DescriptionFormatter
    include ActionView::Helpers::SanitizeHelper
    include CommoditiesHelper

    ALLOWED_SOURCE_TAGS = %w[br sub sup].freeze
    ALLOWED_RESULT_TAGS = %w[a br sub sup].freeze
    ALLOWED_RESULT_ATTRIBUTES = %w[href rel target].freeze

    def initialize(text)
      @text = text.to_s
    end

    def to_html
      fragment = Nokogiri::HTML::DocumentFragment.parse(linkified_text)
      add_link_attributes(fragment)

      sanitize(
        fragment.to_html,
        tags: ALLOWED_RESULT_TAGS,
        attributes: ALLOWED_RESULT_ATTRIBUTES,
      ).html_safe
    end

    private

    def linkified_text
      convert_text_to_links(
        sanitize(@text, tags: ALLOWED_SOURCE_TAGS, attributes: []),
      )
    end

    def add_link_attributes(fragment)
      fragment.css('a').each do |link|
        link['target'] = '_blank'
        link['rel'] = 'noopener noreferrer'
      end
    end

    def url_options = {}
  end
end
