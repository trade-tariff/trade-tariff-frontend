class NewsItemsController < ApplicationController
  before_action :disable_search_form,
                :disable_last_updated_footnote

  def index
    @filter_collection = params[:collection_id].presence&.to_i
    @filter_year = params[:year].presence&.to_i

    @news_collections = News::Collection.all
    @news_years = News::Year.all

    @news_items = News::Item.updates_page(**news_index_params)
  end

  def show
    @news_item = News::Item.find(params[:id])
    @news_collection = @news_item.collections.first || News::Collection.new
  end

private

  def news_index_params
    params.permit(:page, :year, :collection_id)
          .to_h
          .symbolize_keys
  end
  helper_method :news_index_params
end
