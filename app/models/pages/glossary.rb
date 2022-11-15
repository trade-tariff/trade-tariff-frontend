module Pages
  class Glossary
    PAGES = {
      'EXW' => 'Ex-works price',
      'FOB' => 'Free on board price',
      'MaxNOM' => 'Maximum value of non-originating materials',
      'RVC' => 'minimum regional value content',
      'VNM' => 'Value of non-originating materials',
    }.freeze

    PAGE_KEYS = Hash[PAGES.keys.map(&:underscore).zip(PAGES.keys)].freeze

    attr_reader :key, :term, :title

    class << self
      def pages
        PAGE_KEYS.keys
      end

      def find(term)
        raise UnknownPage unless pages.include?(term)

        new(term)
      end

      def all
        pages.map(&method(:find))
      end

    private

      def templates
        Dir[Rails.root.join('app/views/pages/glossary/_*.html.erb')]
      end
    end

    def initialize(key)
      @key = key
      @term = PAGE_KEYS[key]
      @title = PAGES[term]
    end

    def term_and_title
      "#{@term} (#{@title})"
    end

    class UnknownPage < StandardError; end
  end
end
