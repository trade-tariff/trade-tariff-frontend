module MeasureTypes
  class PreferenceCodesController < ApplicationController
    before_action :disable_search_form,
                  :disable_last_updated_footnote

    def show
      # pass the geographical area id to the description
      # assign the geographical area id after we've fetched the measure type
      @measure_type = MeasureType.find(params[:measure_type_id])
      @measure_type.geographical_area_id = params[:geographical_area_id]
      @preference_code = PreferenceCode.find(params[:id])
    end
  end
end
