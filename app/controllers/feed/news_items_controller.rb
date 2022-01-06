module Feed
  class NewsItemsController < ApplicationController
    def index
      @news_items = NewsItem.for_feed
    end
  end
end
