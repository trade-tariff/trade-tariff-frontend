class MeasureTypeController < ApplicationController
  before_action :disable_search_form,
                :disable_last_updated_footnote

  def show
    @measure_type = MeasureType.find(params[:measure_type_id])
    @preference_code = PreferenceCode.find(params[:preference_code_id])
  end
end
