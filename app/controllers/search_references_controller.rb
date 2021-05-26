class SearchReferencesController < ApplicationController
  def show
    @no_shared_switch_service_link = true
    @search_references = SearchReferencesPresenter.new(
      SearchReference.all(query: { letter: letter })
                     .select { |ref| ref.attributes['referenced_class'] != 'Commodity' }
    )
  end

  private

  def letter
    params.fetch(:letter, 'a')
  end
  helper_method :letter
end
