class ChangeDatesController < ApplicationController
  include DeclarableHelper

  before_action :disable_search_form

  def show
    @change_date = ChangeDate.new(show_change_date_params)
  end

  def update
    @change_date = ChangeDate.new(update_change_date_params)

    if @change_date.errors.messages.any?
      render 'show'
    else
      redirect_to goods_nomenclature_path(
        day: @change_date.day,
        month: @change_date.month,
        year: @change_date.year,
      )
    end
  end

  private

  def update_change_date_params
    params.require(:change_date).permit(
      :'import_date(3i)',
      :'import_date(2i)',
      :'import_date(1i)',
    )
  end

  def show_change_date_params
    change_date_params = if params[:day] && params[:month] && params[:year]
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

    ActionController::Parameters.new(change_date_params).permit(
      :'import_date(3i)',
      :'import_date(2i)',
      :'import_date(1i)',
    )
  end

  def today
    @today ||= Time.zone.today
  end
end
