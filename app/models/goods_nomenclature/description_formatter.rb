class GoodsNomenclature
  class DescriptionFormatter
    include ActionView::Helpers::SanitizeHelper

    ALLOWED_SOURCE_TAGS = %w[br sub sup].freeze

    def initialize(text)
      @text = text.to_s
    end

    def to_html
      sanitize(
        @text,
        tags: ALLOWED_SOURCE_TAGS,
        attributes: [],
      ).html_safe
    end
  end
end
