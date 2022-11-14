module Pages
  class Glossary
    PAGE_GLOB = Rails.root.join('app/views/pages/glossary/_*.html.erb')

    attr_reader :term

    class << self
      def pages
        @pages ||= Dir[PAGE_GLOB].map do |f|
          File.basename(f, '.html.erb').slice(1..)
        end
      end

      def find(term)
        raise UnknownPage unless pages.include?(term)

        new(term)
      end

    private

      def templates
        Dir[Rails.root.join('app/views/pages/glossary/_*.html.erb')]
      end
    end

    def initialize(term)
      @term = term
    end

    def page
      "pages/glossary/#{term}"
    end

    class UnknownPage < StandardError; end
  end
end
