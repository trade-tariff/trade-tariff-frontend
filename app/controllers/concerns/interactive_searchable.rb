module InteractiveSearchable
  extend ActiveSupport::Concern

  private

  def perform_interactive_search
    if validate_interactive_search == :invalid
      render_interactive_search_page(outcome: 'input_error')
      return
    end

    return render_interactive_question if validate_interactive_answer == :invalid

    merge_current_answer

    @results = @search.perform
    sync_interactive_request_id

    if @search.errors.any?
      render_interactive_search_page(outcome: 'backend_error')
      return
    end

    respond_to do |format|
      format.html { route_interactive_results }
      format.json { render json: SearchPresenter.new(@search, @results) }
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

    @form = InteractiveSearchForm.new(
      q: params[:q],
      answer: params.dig(:interactive_search_form, :answer),
      request_id: params[:request_id],
    )

    return if @form.valid?(:answer)

    @results = build_result_from_params
    :invalid
  end

  def interactive_search?
    @search.interactive_search && interactive_search_enabled?
  end

  def sync_interactive_request_id
    return unless @results.respond_to?(:request_id) && @results.request_id.present?

    @search.request_id = @results.request_id
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
    record_guided_search_journey(outcome: 'question')
    render :interactive_question
  end

  def render_interactive_no_results
    disable_switch_service_banner
    disable_search_form
    mark_interactive_search_page
    record_guided_search_journey(outcome: 'no_results')
    render :interactive_no_results
  end

  def render_interactive_unknown_results
    disable_switch_service_banner
    disable_search_form
    mark_interactive_search_page
    record_guided_search_journey(outcome: 'unknown_results')
    render :interactive_unknown_results
  end

  def render_interactive_blocking
    disable_switch_service_banner
    disable_search_form
    mark_interactive_search_page
    record_guided_search_journey(outcome: 'blocking_guidance')
    render :interactive_blocking
  end

  def render_interactive_results
    disable_switch_service_banner
    disable_search_form
    mark_interactive_search_page
    record_guided_search_journey(outcome: 'results')
    render :interactive_results
  end

  def render_interactive_search_page(outcome:)
    @no_shared_search = true
    @hero_story = nil
    @recent_stories = []
    record_guided_search_journey(outcome:)
    render 'find_commodities/show_interactive'
  end

  def mark_interactive_search_page
    @interactive_search_page = true
  end

  def record_guided_search_journey(outcome:)
    @guided_search_outcome = outcome
    current_question = @results&.current_question

    GuidedSearch::JourneyInstrumentation.record(
      browser_session_id: guided_search_browser_session_id,
      request_id: @search.request_id,
      outcome:,
      question_count: @results&.answered_questions&.size.to_i + (current_question.present? ? 1 : 0),
      option_count: Array(current_question&.dig('options')).size,
      result_count: @results&.size.to_i,
      client_elapsed_ms: bounded_integer(params[:client_elapsed_ms], maximum: 86_400_000),
      experiment: @search.experiment,
    )
  end

  def guided_search_browser_session_id
    raw_id = session[:guided_search_browser_session_id] ||= SecureRandom.uuid
    GuidedSearch::JourneyInstrumentation.browser_session_id(raw_id)
  end
end
