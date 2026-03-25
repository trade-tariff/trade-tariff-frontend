class SearchResultsPresenter
  attr_reader :search_form, :search_result, :with_errors

  def initialize(search_form)
    @with_errors = false
    @search_form = search_form
    @search_result = search_form.present? ? self.class.model_class.search(search_form.to_params) : self.class.empty_result
  rescue Faraday::ResourceNotFound
    handle_resource_not_found
  rescue StandardError
    @with_errors = true
  end

  class << self
    def model_class
      raise NotImplementedError, "#{name} must define model_class"
    end

    def empty_result = nil
  end

  private

  def handle_resource_not_found
    @with_errors = true
  end
end
