module InteractiveSearchable
  extend ActiveSupport::Concern

  private

  def perform_interactive_search
    return if validate_internal_search == :invalid
    return render_interactive_question if validate_interactive_answer == :invalid

    merge_current_answer

    @results = @search.perform

    respond_to do |format|
      format.html { route_interactive_results }
      format.json { render json: SearchPresenter.new(@search, @results) }
      format.atom
    end
  end

  def route_interactive_results
    if skip_questions?
      render_interactive_results
    elsif @results.has_pending_question?
      render_interactive_question
    else
      render_interactive_results
    end
  end

  def validate_internal_search
    @form = InternalSearchForm.new(q: params[:q], request_id: params[:request_id])

    unless @form.valid?
      @results = Search::InternalSearchResult.new([], nil)
      return :invalid
    end

    @search.q = @form.q
    nil
  end

  def validate_interactive_answer
    return if params[:current_question].blank?

    @form = InternalSearchForm.new(
      q: params[:q],
      answer: params.dig(:internal_search_form, :answer),
      request_id: params[:request_id],
    )

    return if @form.valid?(:answer)

    @search.answers = completed_answers
    @results = @search.perform
    :invalid
  end

  def internal_search?
    @search.internal_search && TradeTariffFrontend.internal_search_enabled?
  end

  def merge_current_answer
    answer = params.dig(:internal_search_form, :answer)
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

  def skip_questions?
    params[:skip_questions] == 'true' && @results.interactive_search?
  end

  def render_interactive_question
    disable_switch_service_banner
    disable_last_updated_footnote
    disable_search_form
    render :interactive_question
  end

  def render_interactive_results
    disable_switch_service_banner
    disable_last_updated_footnote
    disable_search_form
    render :interactive_results
  end
end
