class AdditionalCodeSearchController < ApplicationController
  def new
    @form = AdditionalCodeSearchForm.new
    @query = {}
    @additional_codes = []

    render 'search/additional_code_search'
  end

  def create
    @form = AdditionalCodeSearchForm.new(additional_code_search_params)
    @form.valid?
    @query = @form.to_params
    @additional_codes = AdditionalCodeSearchService.new(@query).call

    render 'search/additional_code_search'
  end

  def additional_code_search_params
    params.fetch(:additional_code_search_form, {}).permit(:code, :description)
  end
end
