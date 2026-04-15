class QuotaSearchPresenter < SearchResultsPresenter
  def self.model_class = OrderNumber::Definition
  def self.empty_result = []
end
