class ExchangeRatesController < ApplicationController
  before_action :disable_search_form, :disable_switch_service_banner, :disable_last_updated_footnote
  before_action :validate_rate_type!

  def index
    @period_list = ExchangeRates::PeriodList.find(
      params[:year],
      filter: { type: },
    )

    render :show_404, status: :not_found if @period_list.exchange_rate_periods.blank?
  end

  def files
    redirect_to "/uk/api/exchange_rates/files/#{params[:id]}.#{params[:format]}" and return true
  end

  def show
    @exchange_rate_collection = ExchangeRateCollection.find(
      "#{year}-#{month}",
      filter: { type: },
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

  def type
    params[:type] || ExchangeRates::PeriodList::MONTHLY_RATE
  end

  def validate_rate_type!
    unless ExchangeRates::PeriodList.valid_rate_type?(type)
      render :show_404, status: :not_found
    end
  end
end
