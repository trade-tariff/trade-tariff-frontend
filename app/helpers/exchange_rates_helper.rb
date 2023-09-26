module ExchangeRatesHelper
  def filter_years(years, year_to_hide)
    years.reject { |year| year.year == year_to_hide || year.year == ExchangeRates::Year::HIDDEN_YEAR }
  end

  def related_information_sidebar_list_items(type)
    case type
    when 'scheduled'
      [
        list_item_for('Average rates', :average),
        list_item_for('Spot rates', :spot),
      ]
    when 'spot'
      [
        list_item_for('Average rates', :average),
        list_item_for('Monthly rates', :scheduled),
      ]
    when 'average'
      [
        list_item_for('Monthly rates', :scheduled),
        list_item_for('Spot rates', :spot),
      ]
    end.join.html_safe
  end

  def list_item_for(link_text, type)
    content_tag(:li, class: 'gem-c-related-navigation__link') do
      link_to(link_text, exchange_rates_path(type:))
    end
  end
end
