class InternalResultsPresenter
  def initialize(_search, search_results)
    @search_results = search_results
  end

  def as_json(_opts = {})
    @search_results.all.map do |result|
      {
        type: result.class.name.underscore,
        goods_nomenclature_item_id: result.goods_nomenclature_item_id,
        description: result.description,
        formatted_description: result.formatted_description,
        declarable: result.respond_to?(:declarable) ? result.declarable : false,
        score: result.respond_to?(:score) ? result.score : nil,
      }
    end
  end
end
