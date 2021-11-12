class ChemicalSearchPresenter
  attr_reader :search_form, :search_result, :with_errors

  def initialize(search_form)
    @with_errors = false
    @search_form = search_form
    @search_result = Chemical.search(search_form.to_params) if search_form.present?
  rescue Faraday::ResourceNotFound
    # noop - swallow a 404 here so that the UI can display a message to the user
  rescue StandardError
    @with_errors = true
  end
end
