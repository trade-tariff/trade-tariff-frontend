class ChemicalSearchPresenter < SearchResultsPresenter
  def self.model_class = Chemical

  private

  def handle_resource_not_found
    # noop - swallow a 404 here so that the UI can display a message to the user
  end
end
