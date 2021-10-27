class GeographicalAreasController < ApplicationController
  def show
    @no_shared_search = true
    @tariff_last_updated = nil
    @geographical_area = GeographicalArea.find(params[:id], query_params)
  end

  def index
    respond_to do |format|
      format.json do
        results = geographical_areas.map do |geographical_area|
          {
            id: geographical_area.id,
            text: geographical_area.long_description,
          }
        end

        respond_with results: results
      end
    end
  end

  private

  def geographical_areas
    search_term = Regexp.escape(params[:term].to_s)
    GeographicalArea.by_long_description(search_term)
  end
end
