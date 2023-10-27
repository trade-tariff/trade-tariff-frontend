module ExchangeRatesHelper
  def filter_years(years, year_to_hide)
    years.reject { |year| year.year == year_to_hide || year.year == ExchangeRates::Year::HIDDEN_YEAR }
  end

  def related_information_sidebar_list_items(type)
    case type
    when 'monthly'
      [
        list_item_for('Average rates', :average),
        list_item_for('Spot rates', :spot),
      ]
    when 'spot'
      [
        list_item_for('Average rates', :average),
        list_item_for('Monthly rates', :monthly),
      ]
    when 'average'
      [
        list_item_for('Monthly rates', :monthly),
        list_item_for('Spot rates', :spot),
      ]
    end.join.html_safe
  end

  def list_item_for(link_text, type)
    content_tag(:li, class: 'gem-c-related-navigation__link') do
      link_to(link_text, exchange_rates_path(type:))
    end
  end

  def exchange_rates_page_title(type:, year:, month: nil)
    case type
    when 'average'
      'HMRC currency exchange average rates - GOV.UK'
    when 'monthly'
      month_year = month_and_year_name(month, year)

      "#{month_year} HMRC monthly currency exchange rates - GOV.UK".strip
    when 'spot'
      month_year = month_and_year_name(month, year)

      "#{month_year} HMRC currency exchange spot rates - GOV.UK".strip
    else
      raise "Not valid Exchage rate type: '#{type}'"
    end
  end
end
