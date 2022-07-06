class GeographicalAreasController < ApplicationController
  before_action :disable_search_form,
                :disable_switch_service_banner,
                :disable_last_updated_footnote

  def show
    @geographical_area = GeographicalArea.find(params[:id], query_params)
  end
end
