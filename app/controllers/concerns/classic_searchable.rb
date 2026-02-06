module ClassicSearchable
  extend ActiveSupport::Concern

  private

  def perform_classic_search
    @results = @search.perform

    respond_to do |format|
      format.html { route_classic_results }
      format.json { render json: SearchPresenter.new(@search, @results) }
      format.atom
    end
  end

  def route_classic_results
    if @search.missing_search_term?
      redirect_to missing_search_query_fallback_url
    elsif @results.exact_match?
      redirect_to url_for @results.to_param.merge(url_options).merge(request_id: @search.request_id, only_path: true)
    elsif @results.none? && @search.search_term_is_commodity_code?
      redirect_to commodity_path(@search.q, request_id: @search.request_id)
    elsif @results.none? && @search.search_term_is_heading_code?
      redirect_to heading_path(@search.q, request_id: @search.request_id)
    end
  end
end
