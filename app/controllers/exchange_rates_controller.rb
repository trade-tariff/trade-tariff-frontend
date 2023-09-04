class ExchangeRatesController < ApplicationController
  before_action :disable_search_form,
                :disable_switch_service_banner,
                :disable_on_xi

  def index
    @period_list = ExchangeRates::PeriodList.find(params[:year])
  end

  def show
    @monthly_exchange_rate = ExchangeRates::MonthlyExchangeRate.find(
      "#{year}-#{month}",
    )
  end

  private

  def month
    id.split('-').last
  end

  def year
    id.split('-').first
  end

  def id
    params[:id]
  end

  def disable_on_xi
    if TradeTariffFrontend::ServiceChooser.xi?
      raise TradeTariffFrontend::FeatureUnavailable
    end
  end
end
