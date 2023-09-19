class ExchangeRatesController < ApplicationController
  before_action :disable_search_form, :disable_switch_service_banner
  rescue_from Faraday::ResourceNotFound, with: :render_404

  def index
    @period_list = ExchangeRates::PeriodList.find(
      params[:year],
      filter: { type: 'scheduled' },
    )
  end

  def show
    @exchange_rate_collection = ExchangeRateCollection.find(
      "#{year}-#{month}",
      filter: { type: 'scheduled' },
    )
  end

  def index_average_rates
    # TODO: This is temporary using the monthly period.
    #       When BE provides the average rates it will be updated.
    @period_list = ExchangeRates::PeriodList.find(params[:year])
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
