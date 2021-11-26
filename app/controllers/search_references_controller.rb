class SearchReferencesController < ApplicationController
  def show
    @search_references = SearchReferencesPresenter.new(
      SearchReference.all(query: { letter: letter })
                     .reject { |ref| ref.attributes['referenced_class'] == 'Commodity' },
    )
  end

  private

  def letter
    params.fetch(:letter, 'a')
  end
  helper_method :letter
end
