class ImportExportDatesController < ApplicationController
  include GoodsNomenclatureHelper

  before_action :disable_search_form,
                :disable_switch_service_banner,
                :disable_last_updated_footnote,
                :set_goods_nomenclature_code

  def show
    @import_export_date = ImportExportDate.new(show_import_export_date_params)
  end

  def update
    @import_export_date = ImportExportDate.new(
      update_import_export_date_params.except(:goods_nomenclature_code),
    )

    if @import_export_date.valid?
      redirect_to goods_nomenclature_path(
        day: @import_export_date.day,
        month: @import_export_date.month,
        year: @import_export_date.year,
      )
    else
      render 'show'
    end
  end

  private

  def update_import_export_date_params
    params.require(:import_export_date).permit(
      :'import_date(3i)',
      :'import_date(2i)',
      :'import_date(1i)',
      :goods_nomenclature_code,
    )
  end

  def show_import_export_date_params
    import_export_date_params = if params[:day] && params[:month] && params[:year]
                                  {
                                    'import_date(3i)': params[:day],
                                    'import_date(2i)': params[:month],
                                    'import_date(1i)': params[:year],
                                  }
                                else
                                  {
                                    'import_date(3i)': today.day.to_s,
                                    'import_date(2i)': today.month.to_s,
                                    'import_date(1i)': today.year.to_s,
                                  }
                                end

    ActionController::Parameters.new(import_export_date_params).permit(
      :'import_date(3i)',
      :'import_date(2i)',
      :'import_date(1i)',
    )
  end

  def today
    @today ||= Time.zone.today
  end

  def set_goods_nomenclature_code
    @goods_nomenclature_code = params[:goods_nomenclature_code] || # Set by the link to show action query param
      params.fetch(:import_export_date, {})[:goods_nomenclature_code] # Set by the update form submission
  end
end
