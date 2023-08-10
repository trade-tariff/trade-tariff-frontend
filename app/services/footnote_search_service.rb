class FootnoteSearchService
  def initialize(query)
    @query = query
  end

  def call
    if @query.any?
      Footnote.search(@query)
    else
      []
    end
  end
end
