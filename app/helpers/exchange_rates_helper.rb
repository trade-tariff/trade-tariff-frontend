module ExchangeRatesHelper
  def filter_years(years, year_to_hide)
    years.reject { |year| [year_to_hide, ExchangeRates::Year::HIDDEN_YEAR].include?(year.year) }
  end

  def related_information_sidebar_list_items(type)
    case type
    when 'monthly'
      [
        list_item_for('Currency exchange average rates', :average),
        list_item_for('Currency exchange spot rates', :spot),
      ]
    when 'spot'
      [
        list_item_for('Currency exchange average rates', :average),
        list_item_for('Currency exchange monthly rates', :monthly),
      ]
    when 'average'
      [
        list_item_for('Currency exchange monthly rates', :monthly),
        list_item_for('Currency exchange spot rates', :spot),
      ]
    end.join.html_safe
  end

  def list_item_for(link_text, type)
    content_tag(:li, class: 'gem-c-related-navigation__link') do
      link_to(link_text, exchange_rates_path(type:))
    end
  end

  def exchange_rates_page_title(type:, year:, month: nil)
    month_year = month_name_and_year(month, year)

    t("exchange_rates.title.#{type}", month_year:).strip
  end

  def exchange_rates_meta_description(type:, year:, month: nil)
    case type
    when 'average'
      t('exchange_rates.meta_description.average')
    when 'monthly'
      t('exchange_rates.meta_description.monthly', month_year: month_name_and_year(month, year))
    when 'spot'
      if month.present? && year.present?
        t('exchange_rates.meta_description.spot.by_month_and_year', month_year: month_name_and_year(month, year))
      else
        t('exchange_rates.meta_description.spot.generic')
      end
    end
  end
end
