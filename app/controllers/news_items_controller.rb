class NewsItemsController < ApplicationController
  before_action :disable_search_form,
                :disable_switch_service_banner

  def index
    @news_collections = News::Collection.all
    @news_years = News::Year.all

    @filter_year = params[:story_year].presence&.to_i
    if params[:collection_id]
      @filter_collection = @news_collections.find do |collection|
        collection.matches_param? params[:collection_id]
      end
    end

    @news_items = News::Item.updates_page(**news_index_params)
    @listed_news_items = News::AiSearchUpdate.merge(
      @news_items,
      enabled: interactive_search_enabled?,
      year: @filter_year,
      collection: @filter_collection,
      collection_id: params[:collection_id],
      page: params[:page],
      previous_oldest: previous_page_oldest,
    )
  rescue Faraday::ServerError
    redirect_to not_found_path
  end

  def show
    @news_item = News::Item.find(params[:id])
    @news_collection = @news_item.collections.first || News::Collection.new
    @collection_items = News::Item.updates_page(collection_id: @news_collection.id)
                                  .slice(0, 3)
  end

private

  def news_index_params
    params.permit(:page, :story_year, :collection_id)
          .to_h
          .symbolize_keys
  end
  helper_method :news_index_params

  def previous_page_oldest
    page_number = params[:page].to_i
    return if page_number <= 1
    return unless interactive_search_enabled?
    return if @news_items.blank?

    newest = @news_items.first.start_date
    return if newest.blank? || newest.to_date >= News::AiSearchUpdate::START_DATE

    previous_page = News::Item.updates_page(**news_index_params.merge(page: page_number - 1))
    previous_page.last&.start_date
  rescue Faraday::Error
    nil
  end
end
