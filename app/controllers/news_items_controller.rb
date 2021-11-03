class NewsItemsController < ApplicationController
  before_action { @tariff_last_updated = nil }
  before_action { @no_shared_search = true }

  def index
    @news_items = NewsItem.updates_page
  end

  def show
    @news_item = NewsItem.find(params[:id])
  end
end
