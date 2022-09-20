class FindCommoditiesController < ApplicationController
  before_action :disable_switch_service_banner, only: [:show]

  def show
    raise "An Error" if params[:trigger_exception] == 'trigger'

    @no_shared_search = true
    @latest_news = NewsItem.latest_for_home_page
  end
end
