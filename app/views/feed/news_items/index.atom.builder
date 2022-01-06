atom_feed do |feed|
  feed.title t('feed.news_item_title')

  @news_items.each do |news_item|
    feed.entry(
      news_item,
      url: news_item_url(news_item.id),
    ) do |entry|
      entry.title        news_item.title
      entry.content      news_item.content
      entry.start_date   news_item.start_date.try(:to_s, :rfc822) || ''
      entry.end_date     news_item.end_date.try(:to_s, :rfc822) || ''
      entry.uk           news_item.show_on_uk
      entry.xi           news_item.show_on_xi
      entry.home_page    home_url
      entry.updates_page news_items_url
    end
  end
end
