class FootnoteSearchService
  def initialize(query)
    @query = query
  end

  def call
    return [] if @query.none?

    Footnote.search(@query)
  end
end
