class ExchangeRatesController < ApplicationController
  before_action :disable_search_form

  def index
    @period_list = ExchangeRates::PeriodList.find(params[:year])
  end

  def show
    @exchange_rates_list = ExchangeRates::RatesList.all(month: params[:month], year: params[:year])
    @month_and_year = "#{Date::MONTHNAMES[@exchange_rates_list.month]} #{@exchange_rates_list.year}"

    # Need to consider if each file would have adifferent publication date ever between CSV/XML
    @published_date = @exchange_rates_list.exchange_rate_files.first.publication_date
    @file_type = @exchange_rates_list.exchange_rate_files.first.publication_date
  end
end
