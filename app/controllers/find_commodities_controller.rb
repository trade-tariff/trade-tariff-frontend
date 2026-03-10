class FindCommoditiesController < ApplicationController
  before_action :disable_switch_service_banner, only: [:show]

  def show
    @no_shared_search = true
    @hero_story = News::Item.latest_for_home_page
    @recent_stories = News::Item.updates_page.slice(0, 3)

    render :show_interactive if TradeTariffFrontend.interactive_search_enabled?
  end
end
