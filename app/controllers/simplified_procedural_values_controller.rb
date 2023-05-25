class SimplifiedProceduralValuesController < ApplicationController
  before_action :disable_search_form,
                :disable_last_updated_footnote,
                :disable_switch_service_banner

  def index
    if params[:simplified_procedural_code].present?
      simplified_procedural_code_measures_by_code
    else
      simplified_procedural_code_measures_by_date
    end
  end

  def simplified_procedural_code_measures_by_code
    @simplified_procedural_codes = SimplifiedProceduralCodeMeasure.by_code(params[:simplified_procedural_code])
    @simplified_procedural_code = params[:simplified_procedural_code]
    @goods_nomenclature_label = @simplified_procedural_codes.first.goods_nomenclature_label
    @goods_nomenclature_item_ids = @simplified_procedural_codes.first.goods_nomenclature_item_ids
    @by_code = true
  end

  def simplified_procedural_code_measures_by_date
    @validity_start_dates = SimplifiedProceduralCodeMeasure.validity_start_dates
    @simplified_procedural_codes = SimplifiedProceduralCodeMeasure.by_valid_start_date(params[:validity_start_date])
    @validity_start_date = params[:validity_start_date].presence || SimplifiedProceduralCodeMeasure.maximum_validity_start_date
    @validity_end_date = SimplifiedProceduralCodeMeasure.all_date_options[@validity_start_date]
    @by_code = false
  end
end
