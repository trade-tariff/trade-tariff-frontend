class SimplifiedProceduralValuesController < ApplicationController
  before_action :disable_search_form,
                :disable_last_updated_footnote,
                :disable_switch_service_banner

  def index
    @valid_start_dates = SimplifiedProceduralCode.valid_start_dates
    @simplified_procedural_codes = SimplifiedProceduralCode.by_valid_start_date(params[:valid_start_date]) if params[:valid_start_date]
  end
end
