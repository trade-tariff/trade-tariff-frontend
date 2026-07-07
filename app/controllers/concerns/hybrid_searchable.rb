module HybridSearchable
  def hybrid_search?
    hybrid_search_enabled?
  end

  def perform_hybrid_search
    @results = @search.perform

    respond_to do |format|
      format.html { route_hybrid_results }
      format.json { render json: SearchPresenter.new(@search, @results) }
      format.atom
    end
  end

  def route_hybrid_results
    if @results.exact_match?
      redirect_to polymorphic_url(
        @results.exact_match,
        request_id: @search.request_id,
        only_path: true,
      )
    end
  end
end
