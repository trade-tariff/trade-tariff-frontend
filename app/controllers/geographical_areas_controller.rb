class GeographicalAreasController < ApplicationController
  before_action :disable_search_form,
                :disable_switch_service_banner,
                :disable_last_updated_footnote,
                :set_goods_nomenclature_code

  def show
    @geographical_area = GeographicalArea.find(params[:id], query_params)
  end

  private

  def set_goods_nomenclature_code
    @goods_nomenclature_code = params[:goods_nomenclature_code]
  end
end
