class ImportExportDatesController < ApplicationController
  include GoodsNomenclatureHelper
  include GoodsNomenclatureContext

  prepend_before_action :disable_search_form,
                        :disable_switch_service_banner

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

  def goods_nomenclature_context_param
    params[:goods_nomenclature_code].presence || # Set by the link to show action query param
      nested_goods_nomenclature_context_param(:import_export_date) || # Set by the update form submission
      params[:goods_nomenclature_code]
  end
end
