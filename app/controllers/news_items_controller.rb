class NewsItemsController < ApplicationController
  before_action :disable_search_form,
                :disable_last_updated_footnote,
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
end
