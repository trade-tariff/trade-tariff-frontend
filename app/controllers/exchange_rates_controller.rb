class ExchangeRatesController < ApplicationController
  before_action :disable_search_form, :disable_switch_service_banner

  before_action :validate_rate_type!

  def index
    @period_list = ExchangeRates::PeriodList.find(
      params[:year],
      filter: { type: },
    )
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
