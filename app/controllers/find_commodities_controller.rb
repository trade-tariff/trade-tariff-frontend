class FindCommoditiesController < ApplicationController
  before_action :disable_switch_service_banner, only: [:show]

  def show
    @no_shared_search = true
    @hero_story = News::Item.latest_for_home_page
    @recent_stories = News::Item.updates_page.slice(0, 3)

    @find_commodity = FindCommodity.new(search_params)

    return unless search_params[:commit].present? || search_params[:q].present?

    return unless @find_commodity.valid?

    redirect_to perform_search_path redirect_params
  end

  private

  def redirect_params
    search_params.select { |_k, v| v.present? }
  end
end
