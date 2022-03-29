module NewsItemHelper
  def format_news_item_content(content)
    govspeak replace_service_tags content
  end
end
