class FindCommoditiesController < ApplicationController
  def show
    @no_shared_search = true
    @latest_news = NewsItem.latest_for_home_page
  end
end
