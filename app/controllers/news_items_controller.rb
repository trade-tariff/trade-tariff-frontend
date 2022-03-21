class NewsItemsController < ApplicationController
  before_action :disable_search_form,
                :disable_last_updated_footnote

  def index
    @news_items = NewsItem.updates_page
  end

  def show
    @news_item = NewsItem.find(params[:id])
  end
end
