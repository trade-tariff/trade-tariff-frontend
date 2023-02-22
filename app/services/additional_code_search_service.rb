class AdditionalCodeSearchService
  def initialize(query)
    @query = query
  end

  def call
    if @query.any?
      AdditionalCode.search(@query)
    else
      []
    end
  end
end
