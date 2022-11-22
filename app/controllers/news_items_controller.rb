class NewsItemsController < ApplicationController
  before_action :disable_search_form,
                :disable_last_updated_footnote

  def index
    @filter_year = params[:year].presence&.to_i
    @news_items = News::Item.updates_page(page_number, year: @filter_year)
    @news_years = News::Year.all
  end

  def show
    @news_item = News::Item.find(params[:id])
  end

private

  def page_number
    params[:page].presence&.to_i || 1
  end
end
