class ExchangeRatesController < ApplicationController
  def index
    @period_list = ExchangeRates::PeriodList.find(params[:year])
  end
end
