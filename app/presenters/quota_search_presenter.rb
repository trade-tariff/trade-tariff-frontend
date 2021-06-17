class QuotaSearchPresenter
  attr_reader :search_form, :search_result, :with_errors

  def initialize(search_form)
    @with_errors = false
    @search_form = search_form
    @search_result = OrderNumber::Definition.search(search_form.to_params) if search_form.present?
    @search_result.reject! { |result| result.instance_of?(OrderNumber::Definition) && result.quota_definition_sid.negative? }
  rescue StandardError
    @with_errors = true
  end
end
