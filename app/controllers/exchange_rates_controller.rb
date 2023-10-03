class ExchangeRatesController < ApplicationController
  before_action :disable_search_form, :disable_switch_service_banner

  before_action :validate_rate_type!, only: [:index]

  def index
    @period_list = ExchangeRates::PeriodList.find(
      params[:year],
      filter: { type: },
    )
  end

  def show
    @exchange_rate_collection = ExchangeRateCollection.find(
      "#{year}-#{month}",
      filter: { type: 'scheduled' },
    )
  end

  def period_file_list
    [
      { end_date: 'March 2020', filename: '/api/v2/exchange_rates/files/average_csv_2020-03.csv', size: '6.2 KB' },
      { end_date: 'December 2020', filename: '/api/v2/exchange_rates/files/average_csv_2020-12.csv', size: '6.1 KB' },
      { end_date: 'March 2021', filename: '/api/v2/exchange_rates/files/average_csv_2021-03.csv', size: '6.8 KB' },
      { end_date: 'December 2021', filename: '/api/v2/exchange_rates/files/average_csv_2021-12.csv', size: '6.0 KB' },
      { end_date: 'March 2022', filename: '/api/v2/exchange_rates/files/average_csv_2022-03.csv', size: '6.7 KB' },
      { end_date: 'December 2022', filename: '/api/v2/exchange_rates/files/average_csv_2022-12.csv', size: '6.1 KB' },
      { end_date: 'March 2023', filename: '/api/v2/exchange_rates/files/average_csv_2023-03.csv', size: '6.7 KB' },
    ].reverse
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

  def type
    params[:type] || 'scheduled'
  end

  def validate_rate_type!
    unless ExchangeRates::PeriodList.valid_rate_type?(type)
      render :show_404, status: :not_found
    end
  end
end
