class ExchangeRatesController < ApplicationController
  def show
    @period_list = ExchangeRates::PeriodList.find(params[:id])
  end
end
