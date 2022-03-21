class GeographicalAreasController < ApplicationController
  def show
    disable_search_form
    disable_last_updated_footnote
    @geographical_area = GeographicalArea.find(params[:id], query_params)
  end
end
