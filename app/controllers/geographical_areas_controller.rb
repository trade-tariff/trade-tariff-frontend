class GeographicalAreasController < ApplicationController
  def show
    @no_shared_search = true
    @tariff_last_updated = nil
    @geographical_area = GeographicalArea.find(params[:id], query_params)
  end

  def index
    respond_to { |format| format.json { respond_with results: geographical_areas } }
  end

  private

  def geographical_areas
    search_term = Regexp.escape(params[:term].to_s)

    GeographicalArea.by_long_description(search_term)
  end
end
