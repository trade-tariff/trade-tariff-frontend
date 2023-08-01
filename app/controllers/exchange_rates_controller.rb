class ExchangeRatesController < ApplicationController
  before_action :disable_search_form

  def index
    @period_list = ExchangeRates::PeriodList.find(params[:year])
  end
end
