module QueuedGuidedSearchable
  extend ActiveSupport::Concern

  RECOVERY_MESSAGE = 'We could not complete this search. Please try your search again.'.freeze

  def queue_guided_search
    response.headers['Cache-Control'] = 'no-store'
    prepare_search
    return head :not_found unless interactive_search? && TradeTariffFrontend::ServiceChooser.uk?

    if validate_interactive_search == :invalid || validate_interactive_answer == :invalid
      return render json: { error: @form.errors.full_messages.join('. '), validation_failed: true }, status: :unprocessable_content
    end

    merge_current_answer
    # Initialise the app's existing correlation/session identity, not a per-job cookie value.
    browser_session_id
    raise GuidedSearch::QueuedSearch::InvalidResponse unless session.id

    id = GuidedSearch::QueuedSearch.submit(@search)
    token = GuidedSearch::QueuedSearchToken.issue(
      id:, search_key: @search.interactive_search_cache_key, session_id: session.id.public_id,
    )
    # Retire the earlier spike's per-job cookie map. Grants never go in the cookie.
    session.delete(:queued_guided_searches)

    render json: {
      id:,
      token:,
      request_id: @search.request_id,
      date: { year: @search.date.year, month: @search.date.month, day: @search.date.day },
      poll_url: queued_guided_search_path(id:, token:, day: nil, month: nil, year: nil),
    }, status: :accepted
  rescue Search::InvalidDate
    render json: { error: 'You must enter a valid date', validation_failed: true }, status: :unprocessable_content
  rescue Faraday::Error, GuidedSearch::QueuedSearch::InvalidResponse
    render json: { error: RECOVERY_MESSAGE }, status: :service_unavailable
  end

  def queued_guided_search
    response.headers['Cache-Control'] = 'no-store'
    return head :not_found unless queued_search_key.present? && TradeTariffFrontend::ServiceChooser.uk?

    render json: { status: queued_search_state(params[:id]).fetch(:status) }
  rescue Faraday::ResourceNotFound
    head :not_found
  rescue Faraday::Error, GuidedSearch::QueuedSearch::InvalidResponse
    render json: { error: RECOVERY_MESSAGE }, status: :service_unavailable
  end

  private

  def queued_search_key
    polling = action_name == 'queued_guided_search'
    @queued_search_key ||= GuidedSearch::QueuedSearchToken.search_key(
      params[polling ? :token : :queued_search_token],
      id: params[polling ? :id : :queued_search_id], session_id: session.id&.public_id,
    )
  end

  def accepted_queued_search?
    action_name == 'search' && params[:queued_search_id].present? &&
      TradeTariffFrontend::ServiceChooser.uk? && queued_search_key.present?
  end

  def queued_search_owned?
    queued_search_key == @search.interactive_search_cache_key
  end

  def queued_search_result
    response.headers['Cache-Control'] = 'no-store'
    state = queued_search_state(params[:queued_search_id])
    return state[:result] if state[:status] == 'completed'

    unavailable_queued_result
  rescue Faraday::Error, GuidedSearch::QueuedSearch::InvalidResponse
    unavailable_queued_result
  end

  def queued_search_state(id)
    cached = Search.cached_queued_result(id)
    return { status: 'completed', result: cached } if cached

    payload = GuidedSearch::QueuedSearch.find(id)
    return { status: payload.fetch('status') } unless payload['status'] == 'completed'

    result = payload.fetch('result')
    Search.cache_queued_result(id, result)
    { status: 'completed', result: }
  end

  def unavailable_queued_result
    @search.errors.add(:base, RECOVERY_MESSAGE)
    Search::InternalSearchResult.new([], nil)
  end
end
