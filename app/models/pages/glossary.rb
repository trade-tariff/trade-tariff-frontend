module Pages
  class Glossary
    SAFE_TERM = %r{\A[a-z0-9_]+\z}
    PAGE_ROOT = 'pages/glossary'.freeze
    VIEW_ROOT = Rails.root.join('app/views/pages/glossary')

    attr_reader :term

    def initialize(term)
      raise UnsafePageTerm unless term.match? SAFE_TERM

      @term = term
    end

    def page
      raise UnknownPage unless page_exists?

      page_template
    end

    class UnsafePageTerm < StandardError; end
    class UnknownPage < StandardError; end

  private

    def page_template
      File.join(PAGE_ROOT, term)
    end

    def page_exists?
      VIEW_ROOT.join("_#{term}.html.erb").file?
    end
  end
end
