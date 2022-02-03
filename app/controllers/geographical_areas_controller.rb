class GeographicalAreasController < ApplicationController
  def show
    disable_search_form
    @tariff_last_updated = nil
    @geographical_area = GeographicalArea.find(params[:id], query_params)
  end
end
