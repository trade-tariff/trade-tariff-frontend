module MyottHelper
  include ActionView::Helpers::NumberHelper
  def myott_page_title(title = nil, error: false)
    default = 'UK Online Trade Tariff'
    base_title = "#{title} | #{default}"

    if error
      base_title = "Error: #{base_title}"
    end

    if title
      content_for :title, base_title
    else
      content_for(:title) || default
    end
  end

  def my_commodities_page_heading(category, total_commodities_count)
    case category
    when 'active'
      "Active commodities: #{number_with_delimiter(total_commodities_count, delimiter: ',')}"
    when 'expired'
      'Expired commodities'
    when 'invalid'
      'Errors from commodity uploads'
    end
  end
end
