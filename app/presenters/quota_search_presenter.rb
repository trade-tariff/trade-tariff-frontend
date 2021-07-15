class QuotaSearchPresenter
  attr_reader :search_form, :search_result, :with_errors

  def initialize(search_form)
    @with_errors = false
    @search_form = search_form
    @search_result = search_form.present? ? OrderNumber::Definition.search(search_form.to_params) : []
  rescue StandardError
    @with_errors = true
  end
end
