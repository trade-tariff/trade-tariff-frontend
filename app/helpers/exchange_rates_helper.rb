module ExchangeRatesHelper
  def filter_years(years, year_to_hide)
    years.reject { |year| year.year == year_to_hide }
  end
end
