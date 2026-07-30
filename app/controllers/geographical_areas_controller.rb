class GeographicalAreasController < ApplicationController
  include GoodsNomenclatureContext

  prepend_before_action :disable_search_form,
                        :disable_switch_service_banner

  def show
    render 'errors/not_found', status: :not_found if params[:id] == 'countries'
    @geographical_area = find_geographical_area
  end

  private

  def find_geographical_area
    GeographicalArea.find(params[:id], query_params)
  rescue Faraday::ResourceNotFound
    raise if TradeTariffFrontend::ServiceChooser.uk?

    TradeTariffFrontend::ServiceChooser.with_source(:uk) do
      GeographicalArea.find(params[:id], query_params)
    end
  end
end
