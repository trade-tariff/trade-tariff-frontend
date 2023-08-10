class FootnoteSearchController < ApplicationController
  def new
    @form = FootnoteSearchForm.new
    @query = {}
    @footnotes = []

    render 'search/footnote_search'
  end

  def create
    @form = FootnoteSearchForm.new(footnote_search_params)
    @query = @form.to_params

    @footnotes = if @form.valid?
                   FootnoteSearchService.new(@query).call
                 else
                   []
                 end

    render 'search/footnote_search'
  end

  def footnote_search_params
    params.fetch(:footnote_search_form, {}).permit(:code, :description)
  end
end
