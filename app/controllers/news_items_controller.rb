class NewsItemsController < ApplicationController
  before_action :disable_search_form,
                :disable_last_updated_footnote

  def index
    @news_items = News::Item.updates_page(page_number)
  end

  def show
    @news_item = News::Item.find(params[:id])
  end

private

  def page_number
    params[:page].presence&.to_i || 1
  end
end
