class ExchangeRatesController < ApplicationController
  before_action :disable_search_form, :disable_switch_service_banner
  rescue_from Faraday::ResourceNotFound, with: :render_404

  def index
    @period_list = ExchangeRates::PeriodList.find(params[:year])
  end

  def show
    @monthly_exchange_rate = ExchangeRates::MonthlyExchangeRate.find(
      "#{year}-#{month}",
    )
  end

  private

  def render_404
    render :show_404, status: :not_found
  end

  def month
    id.split('-').last
  end

  def year
    id.split('-').first
  end

  def id
    params[:id]
  end
end
