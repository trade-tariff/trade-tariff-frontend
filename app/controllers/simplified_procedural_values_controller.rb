class SimplifiedProceduralValuesController < ApplicationController
  before_action :disable_search_form,
                :disable_switch_service_banner

  def index
    @result = SimplifiedProceduralCodeMeasureFetcherService.new(params).call
  end
end
