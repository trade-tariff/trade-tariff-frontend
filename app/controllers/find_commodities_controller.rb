class FindCommoditiesController < ApplicationController
  before_action :disable_switch_service_banner, only: [:show]

  def show
    @no_shared_search = true
    @hero_story = News::Item.latest_for_home_page
    @recent_stories = []
  end
end
