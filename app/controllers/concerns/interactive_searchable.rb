module InteractiveSearchable
  extend ActiveSupport::Concern

  FAILURE_SUGGESTIONS_SESSION_KEY = :guided_search_failure_codes
  MAX_RETAINED_FAILURE_JOURNEYS = 5
  SEARCH_RESULTS_STATE_TTL = 1.day
  SEARCH_RESULTS_STATE_ID_PATTERN = /\A[a-f0-9]{32}\z/
  SEARCH_RESULTS_STATE_SESSION_KEY = :duty_calculator_search_results_state
  # Reserve room for CookieStore encryption and encoding overhead.
  MAX_SEARCH_RESULTS_SESSION_BYTES = 2_500

private

  def duty_calculator_back? = duty_calculator_journey? && params[:duty_calculator_back].to_s == 'true'

  def render_duty_calculator_previous_question
    previous_answers = Array(params[:answers]).map { |answer| answer.to_unsafe_h.stringify_keys }
    @duty_calculator_preselected_answer = params[:back_answer].to_s
    @results = Search::InternalSearchResult.new([], {
      'interactive_search' => {
        'query' => @search.q,
        'request_id' => @search.request_id,
        'expanded_query' => params[:expanded_query],
        'query_expansion' => Search::QueryExpansion.parse(params[:query_expansion]),
        'answers' => previous_answers + [{ 'question' => params[:back_question].to_s,
                                           'options' => duty_calculator_back_options,
                                           'answer' => nil }],
      }.compact,
    })
    @form = InteractiveSearchForm.new
    render_interactive_question
  end

  def duty_calculator_back_options
    options = params[:back_options]
    Array(options.is_a?(String) ? JSON.parse(options) : options)
  rescue JSON::ParserError
    []
  end

  def perform_interactive_search
    record_direct_initial_submission

    if validate_interactive_search == :invalid
      render_interactive_search_page(outcome: 'input_error')
      return
    end

    if validate_interactive_answer == :invalid
      prepare_search_failure_suggestions
      return render_interactive_question
    end

    if params[:queued_search_id].present?
      merge_current_answer
      return head :not_found unless queued_search_owned?
    else
      record_accepted_answer
      merge_current_answer
    end

    @results = params[:queued_search_id].present? ? queued_search_result : @search.perform
    sync_interactive_request_id
    prepare_search_failure_suggestions

    if @search.errors.any?
      render_interactive_search_page(outcome: 'backend_error')
      return
    end

    respond_to do |format|
      format.html { route_interactive_results }
      format.json do
        render json: SearchPresenter.new(@search, @results)
        clear_search_failure_suggestions unless @results.has_pending_question?
      end
      format.atom
    end
  end

  def route_interactive_results
    if @results.exact_match?
      render_interactive_results
    elsif @results.has_pending_question?
      @form = InteractiveSearchForm.new
      render_interactive_question
    elsif @results.blocking_guidance?
      return redirect_to_interactive_blocking if redirectable_interactive_blocking?

      render_interactive_blocking
    elsif @results.all_unknown_confidence?
      render_interactive_unknown_results
    elsif @results.none?
      render_interactive_no_results
    else
      render_interactive_results
    end
  end

  def validate_interactive_search
    @form = InteractiveSearchForm.new(q: params[:q], request_id: params[:request_id])

    unless @form.valid?
      @form.errors.each { |error| @search.errors.add(error.attribute, error.message) }
      @results = Search::InternalSearchResult.new([], nil)
      return :invalid
    end

    @search.q = @form.q
    nil
  end

  def validate_interactive_answer
    return if params[:current_question].blank?

    @form.answer = params.dig(:interactive_search_form, :answer)
    valid = @form.valid?(:answer)

    return if valid

    @results = build_result_from_params
    :invalid
  end

  def interactive_search?
    @search.interactive_search && (accepted_queued_search? || interactive_search_enabled_with_analytics?)
  end

  def sync_interactive_request_id
    return unless @results.respond_to?(:request_id) && @results.request_id.present?

    @search.request_id = @results.request_id
  end

  def prepare_search_failure_suggestions
    suggestions = GuidedSearch::FailureSuggestions.new
    retained = retained_search_failure_codes.filter_map { |request_id, retained_codes|
      enabled_codes = suggestions.enabled_codes_for(retained_codes)
      [request_id, enabled_codes] if enabled_codes.any?
    }.to_h
    retained_codes = retained.fetch(@search.request_id, [])
    codes = suggestions.enabled_codes_for(Array(retained_codes) + @results.search_failures)

    if codes.any?
      retained.delete(@search.request_id)
      retained[@search.request_id] = codes
      retained = retained.to_a.last(MAX_RETAINED_FAILURE_JOURNEYS).to_h
    end
    store_search_failure_codes(retained)

    @search_failure_suggestions = codes
  end

  def redirectable_interactive_blocking?
    request.post? && params[:request_id].blank?
  end

  def redirect_to_interactive_blocking
    redirect_to perform_search_path(
      search_params.to_h.merge(
        interactive_search: 'true',
        request_id: @search.request_id,
        expanded_query: @results.expanded_query,
        query_expansion: @results.query_expansion_json,
      ).compact,
    )
  end

  def merge_current_answer
    answer = params.dig(:interactive_search_form, :answer)
    return if answer.blank?

    current_question = params[:current_question]
    current_options = params[:current_options]

    new_entry = {
      question: current_question,
      options: current_options,
      answer: answer,
    }.compact

    @search.answers = Array(@search.answers) + [new_entry] if new_entry[:question].present?
  end

  def completed_answers
    return [] if params[:answers].blank?

    Array(params[:answers]).select do |a|
      h = a.respond_to?(:to_unsafe_h) ? a.to_unsafe_h : a.to_h
      h.stringify_keys['answer'].present?
    end
  end

  def build_result_from_params
    answers = completed_answers.map { |a| a.respond_to?(:to_unsafe_h) ? a.to_unsafe_h : a.to_h }
    current = { 'question' => params[:current_question], 'options' => parse_options(params[:current_options]), 'answer' => nil }

    meta = {
      'interactive_search' => {
        'request_id' => params[:request_id],
        'query' => params[:q],
        'expanded_query' => params[:expanded_query],
        'query_expansion' => Search::QueryExpansion.parse(params[:query_expansion]),
        'answers' => answers + [current],
      }.compact,
    }

    Search::InternalSearchResult.new([], meta)
  end

  def parse_options(value)
    return [] if value.blank?

    JSON.parse(value)
  rescue JSON::ParserError
    []
  end

  def render_interactive_question
    disable_switch_service_banner
    disable_search_form
    mark_interactive_search_page
    assign_question_identity
    record_guided_search_journey(outcome: 'question')
    render :interactive_question
  end

  def render_interactive_no_results
    disable_switch_service_banner
    disable_search_form
    mark_interactive_search_page
    record_guided_search_journey(outcome: 'no_results')
    render :interactive_no_results
    clear_search_failure_suggestions
  end

  def render_interactive_unknown_results
    disable_switch_service_banner
    disable_search_form
    mark_interactive_search_page
    record_guided_search_journey(outcome: 'unknown_results')
    render :interactive_unknown_results
    clear_search_failure_suggestions
  end

  def render_interactive_blocking
    disable_switch_service_banner
    disable_search_form
    mark_interactive_search_page
    record_guided_search_journey(outcome: 'blocking_guidance')
    render :interactive_blocking
    clear_search_failure_suggestions
  end

  def render_interactive_results
    disable_switch_service_banner
    disable_search_form
    mark_interactive_search_page
    record_guided_search_journey(outcome: 'results')
    @duty_calculator_search_results_path = store_duty_calculator_search_state if duty_calculator_journey?
    render :interactive_results
    clear_search_failure_suggestions
  end

  def restore_duty_calculator_search_state
    identifier = params[:search_results_id].to_s
    return unless SEARCH_RESULTS_STATE_ID_PATTERN.match?(identifier)

    state = Rails.cache.resilient_read(duty_calculator_search_state_cache_key(identifier))
    session_state = session[SEARCH_RESULTS_STATE_SESSION_KEY]
    state ||= session_state['state'] if session_state.is_a?(Hash) && session_state['identifier'] == identifier
    return redirect_to_duty_calculator_search_restart unless state.is_a?(Hash)

    state.each { |key, value| params[key] = value }
  rescue StandardError => e
    Rails.logger.warn("Failed to restore calculator search results state: #{e.class}")
    redirect_to_duty_calculator_search_restart
  end

  def store_duty_calculator_search_state
    identifier = SecureRandom.hex(16)
    state = {
      q: @search.q,
      interactive_search: 'true',
      answers: Array(@search.answers).map do |answer|
        answer.respond_to?(:to_unsafe_h) ? answer.to_unsafe_h : answer.to_h
      end,
      request_id: @search.request_id,
      expanded_query: @search.expanded_query,
      query_expansion: Search::QueryExpansion.dump(@search.query_expansion),
      day: @search.date.day,
      month: @search.date.month,
      year: @search.date.year,
      country: @search.country,
      duty_calculator: 'true',
    }.compact
    cache_key = duty_calculator_search_state_cache_key(identifier)
    cache_written = cache_duty_calculator_search_state(cache_key, state)

    if cache_written
      session.delete(SEARCH_RESULTS_STATE_SESSION_KEY)
    elsif !store_duty_calculator_search_state_in_session(identifier, state)
      Rails.logger.warn('Calculator search results state exceeds the session size limit')
      return duty_calculator_search_restart_path
    end

    perform_search_path(search_results_id: identifier)
  rescue StandardError => e
    Rails.logger.warn("Failed to store calculator search results state: #{e.class}")
    nil
  end

  def store_duty_calculator_search_state_in_session(identifier, state)
    fallback = { 'identifier' => identifier, 'state' => state }
    session.delete(SEARCH_RESULTS_STATE_SESSION_KEY)
    serialized_session = JSON.generate(session.to_hash.merge(SEARCH_RESULTS_STATE_SESSION_KEY => fallback))
    return false if serialized_session.bytesize > MAX_SEARCH_RESULTS_SESSION_BYTES

    session[SEARCH_RESULTS_STATE_SESSION_KEY] = fallback
    true
  rescue JSON::GeneratorError, TypeError
    session.delete(SEARCH_RESULTS_STATE_SESSION_KEY)
    false
  end

  def cache_duty_calculator_search_state(cache_key, state)
    cache = Rails.cache
    return false unless cache.resilient_write(cache_key, state, expires_in: SEARCH_RESULTS_STATE_TTL)

    cache.resilient_read(cache_key) == state
  rescue StandardError => e
    Rails.logger.warn("Failed to cache calculator search results state: #{e.class}")
    false
  end

  def redirect_to_duty_calculator_search_restart
    session.delete(SEARCH_RESULTS_STATE_SESSION_KEY)
    redirect_to duty_calculator_search_restart_path
  end

  def duty_calculator_search_restart_path
    what_are_you_importing_path(day: nil, month: nil, year: nil)
  end

  def duty_calculator_search_state_cache_key(identifier)
    "duty_calculator/search_results/#{TradeTariffFrontend::ServiceChooser.service_name}/#{identifier}"
  end

  def render_interactive_search_page(outcome:)
    @no_shared_search = true
    @hero_story = nil
    @recent_stories = []
    record_guided_search_journey(outcome:)
    render find_commodity_template
    clear_search_failure_suggestions
  end

  def clear_search_failure_suggestions
    retained = retained_search_failure_codes
    retained.delete(@search.request_id)
    store_search_failure_codes(retained)
  end

  def retained_search_failure_codes
    session[FAILURE_SUGGESTIONS_SESSION_KEY].to_h
  end

  def store_search_failure_codes(retained)
    if retained.any?
      session[FAILURE_SUGGESTIONS_SESSION_KEY] = retained
    else
      session.delete(FAILURE_SUGGESTIONS_SESSION_KEY)
    end
  end

  def mark_interactive_search_page
    @interactive_search_page = true
  end

  def record_guided_search_journey(outcome:)
    @guided_search_outcome = outcome
    current_question = @results&.current_question
    @guided_search_metrics = {
      question_count: @results&.answered_questions&.size.to_i + (current_question.present? ? 1 : 0),
      option_count: Array(current_question&.dig('options')).size,
      result_count: @results&.size.to_i,
      client_elapsed_ms: bounded_integer(params[:client_elapsed_ms], maximum: 86_400_000),
    }

    GuidedSearch::JourneyInstrumentation.record(
      browser_session_id:,
      request_id: @search.request_id,
      outcome:,
      **@guided_search_metrics,
      experiment: @search.experiment,
    )
  end

  def assign_question_identity
    question = @results&.current_question
    return if question.blank?

    @guided_search_question_id = GuidedSearch::JourneyInstrumentation.question_id(
      request_id: @search.request_id,
      question_number: @results.answered_questions.size + 1,
      question: question['question'],
      options: question['options'],
    )
  end

  def record_accepted_answer
    return if params[:current_question].blank?
    return unless selected_answer_allowed?

    question_id = guided_answer_question_id
    return if question_id.blank?

    submission_id = safe_guided_search_identifier(params[:telemetry_submission_id])
    GuidedSearch::JourneyInstrumentation.record(
      browser_session_id:,
      request_id: @search.request_id,
      question_id:,
      submission_id:,
      question_count: completed_answers.size + 1,
      outcome: 'answer_accepted',
      response_source: 'server_accepted',
      question_response: 'normal',
      event_id: Digest::SHA256.hexdigest(['answer_accepted', @search.request_id, question_id, submission_id].join(':')),
      experiment: @search.experiment,
    )
  rescue StandardError => e
    Rails.logger.warn("Failed to record guided search accepted answer: #{e.class}: #{e.message}")
    nil
  end

  def selected_answer_allowed?
    answer = params.dig(:interactive_search_form, :answer).to_s
    return false if answer.blank? || answer == "I don't know"

    parse_options(params[:current_options]).include?(answer)
  end

  def guided_answer_question_id
    GuidedSearch::JourneyInstrumentation.question_id(
      request_id: @search.request_id,
      question_number: completed_answers.size + 1,
      question: params[:current_question],
      options: parse_options(params[:current_options]),
    )
  end

  def record_direct_initial_submission
    return unless request.post?
    return if params[:queued_search_id].present? || params[:current_question].present?
    return if params[:telemetry_submission_id].present?

    GuidedSearch::JourneyInstrumentation.record(
      browser_session_id:,
      request_id: @search.request_id,
      experiment: @search.experiment,
      outcome: 'initial_submitted',
      submission_source: 'server_direct',
      submission_id: SecureRandom.uuid,
      event_id: SecureRandom.uuid,
    )
  rescue StandardError
    nil
  end
end
