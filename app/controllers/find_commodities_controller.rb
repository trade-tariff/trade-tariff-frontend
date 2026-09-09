class FindCommoditiesController < ApplicationController
  include FindCommodityPage

  before_action :disable_switch_service_banner, only: [:show]

  def show
    @no_shared_search = true
    template = find_commodity_template
    @hero_story = News::Item.latest_for_home_page unless @revised_find_commodity
    @recent_stories = News::Item.updates_page.slice(0, 3)

    render template
  end
end
