module InteractiveSearchable
  extend ActiveSupport::Concern

  private

  def perform_interactive_search
    return if validate_interactive_search == :invalid
    return render_interactive_question if validate_interactive_answer == :invalid

    merge_current_answer

    @results = @search.perform

    if @search.errors.any?
      @results = Search::InternalSearchResult.new([], nil)
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
      redirect_to url_for @results.to_param.merge(url_options).merge(request_id: @search.request_id, only_path: true)
    elsif @results.has_pending_question?
      render_interactive_question
    else
      render_interactive_results
    end
  end

  def validate_interactive_search
    @form = InteractiveSearchForm.new(q: params[:q], request_id: params[:request_id])

    unless @form.valid?
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
    @search.interactive_search && TradeTariffFrontend.interactive_search_enabled?
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
        'answers' => answers + [current],
      },
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
