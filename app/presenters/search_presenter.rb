class SearchPresenter
  def initialize(search, results)
    @search = search
    @search_results = "#{results.type.camelize}ResultsPresenter".constantize.new(search, results)
  end

  def as_json(opts = {})
    {
      q: @search.q,
      as_of: @search.date.to_s,
      results: @search_results.as_json(opts),
    }
  end
end
