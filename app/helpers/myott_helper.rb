module MyottHelper
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
end
