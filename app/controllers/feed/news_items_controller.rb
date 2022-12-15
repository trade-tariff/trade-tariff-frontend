module Feed
  class NewsItemsController < ApplicationController
    def index
      @news_items = News::Item.for_feed
    end
  end
end
