module NewsItemHelper
  def format_news_item_content(content)
    govspeak replace_service_tags content
  end

  # Copied from Kramdown source code, see Kramdown::Convertors::Base#basic_generate_id
  def markdown_heading_id(heading)
    heading.gsub(/^[^a-zA-Z]+/, '')
           .tr('^a-zA-Z0-9 -', '')
           .tr(' ', '-')
           .downcase
  end
end
