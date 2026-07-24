require 'addressable/uri'

class SearchController < ApplicationController
  include GoodsNomenclatureHelper
  include ClassicSearchable
  include InteractiveSearchable

  skip_before_action :verify_authenticity_token, only: [:search]

  before_action :disable_switch_service_banner, only: [:quota_search]
  before_action :disable_search_form, except: [:search]

  def search
    params[:q] = search_attribute_params[:q] if params[:q].blank? && search_attribute_params[:q].present?

    @search.q = params[:q] if params[:q]
    @search.interactive_search = params[:interactive_search] == 'true'
    @search.answers = params[:answers] if params[:answers].present?
    @search.request_id = if @search.interactive_search
                           safe_guided_search_identifier(params[:request_id]) || SecureRandom.uuid
                         else
                           params[:request_id].presence || SecureRandom.uuid
                         end
    @search.expanded_query = params[:expanded_query].presence

    if interactive_search?
      perform_interactive_search
    else
      perform_classic_search
    end
  rescue Search::InvalidDate
    redirect_to find_commodity_path(search_params.merge(invalid_date: true))
  end

  def suggestions
    search_term = Regexp.escape(params[:term].to_s.strip)
    render_suggestions(SearchSuggestion.all(q: search_term))
  end

  def interactive_suggestions
    return suggestions unless interactive_search_enabled?

    search_term = Regexp.escape(params[:term].to_s.strip)

    api_host = TradeTariffFrontend::ServiceChooser.api_host
    path = "#{URI.parse(api_host).path.sub(%r{/api\b}, '/internal')}/search_suggestions"

    response = TradeTariffFrontend::ServiceChooser.api_client.get(path, q: search_term)
    parsed = TariffJsonapiParser.new(response.body).parse
    parsed = [] unless parsed.is_a?(Array)

    render_suggestions(parsed.map { |attrs| SearchSuggestion.new(attrs) })
  end

  def journey_event
    event = guided_search_event_params
    event_attributes = guided_search_event_attributes(event)
    request_id = safe_guided_search_identifier(event[:request_id])
    return head :unprocessable_content if event_attributes.nil? || request_id.nil?

    GuidedSearch::JourneyInstrumentation.record(
      browser_session_id: guided_search_browser_session_id,
      request_id:,
      experiment: Current.experiment,
      **event_attributes,
    )

    head :no_content
  end

  def quota_search
    if TradeTariffFrontend::ServiceChooser.xi?
      raise TradeTariffFrontend::FeatureUnavailable
    end

    if quota_search_date_redirect_required?
      return redirect_to(quota_search_path(canonical_quota_search_query))
    end

    form = QuotaSearchForm.new(quota_search_params)
    @result = QuotaSearchPresenter.new(form)
  end

  def chemical_search
    form = ChemicalSearchForm.new(params.permit(:cas, :name, :page))
    @result = ChemicalSearchPresenter.new(form)

    respond_to do |format|
      format.html
    end
  end

  private

  def guided_search_event_params
    params.permit(
      :event_type,
      :request_id,
      :question_number,
      :client_elapsed_ms,
      :goods_nomenclature_item_id,
      :result_rank,
      :confidence,
      :destination,
      :client_navigation_ms,
    )
  end

  def guided_search_event_attributes(event)
    case event[:event_type]
    when 'dont_know'
      question_count = bounded_integer(event[:question_number], maximum: 100)
      client_elapsed_ms = bounded_integer(event[:client_elapsed_ms], maximum: 86_400_000)
      return if question_count.nil? || client_elapsed_ms.nil?

      {
        outcome: 'dont_know',
        used_dont_know: true,
        question_count:,
        client_elapsed_ms:,
      }
    when 'result_selected'
      goods_nomenclature_item_id = event[:goods_nomenclature_item_id].to_s[/\A\d{10}\z/]
      result_rank = bounded_integer(event[:result_rank], maximum: 100)
      confidence = event[:confidence].to_s.downcase[/\A(strong|good|possible|unlikely|unknown)\z/]
      return if [goods_nomenclature_item_id, result_rank, confidence].any?(&:nil?)

      {
        outcome: 'result_selected',
        goods_nomenclature_item_id:,
        result_rank:,
        confidence:,
      }
    when 'page_visible'
      destination = event[:destination].to_s[
        /\A(question|results|no_results|unknown_results|blocking_guidance|input_error|backend_error)\z/,
      ]
      client_navigation_ms = bounded_integer(event[:client_navigation_ms], maximum: 86_400_000)
      return if destination.nil? || client_navigation_ms.nil?

      {
        outcome: 'page_visible',
        destination:,
        client_navigation_ms:,
      }
    end
  end

  def safe_guided_search_identifier(value)
    identifier = value.to_s
    identifier.match?(/\A[a-zA-Z0-9-]{1,64}\z/) ? identifier : nil
  end

  def bounded_integer(value, maximum:)
    Integer(value, exception: false)&.clamp(0, maximum)
  end

  def render_suggestions(suggestions)
    results = suggestions.map do |s|
      {
        id: s.value,
        text: s.value,
        query: s.query,
        resource_id: s.resource_id,
        formatted_suggestion_type: s.formatted_suggestion_type,
      }
    end

    render json: { results: }
  end

  def anchor
    params.dig(:search, :anchor).to_s.gsub(/[^a-zA-Z_-]/, '').presence
  end

  def missing_search_query_fallback_url
    return find_commodity_path(anchor:) if request.referer.blank?

    back_url = URI(request.referer)
    if back_url.host.present? && back_url.host != request.host
      return find_commodity_path(anchor:)
    end

    query_values = Rack::Utils.parse_query(back_url.query || '')
    query_values = query_values.merge(@search.query_attributes)
    query_values = query_values.tap { |qv| qv.delete('invalid_date') }

    back_url.query = if @search.date.today?
                       CGI.unescape(query_values.except('year', 'month', 'day').to_query)
                     else
                       CGI.unescape(query_values.to_query)
                     end
    back_url.fragment = anchor
    back_url.to_s
  end

  def search_attributes
    search_attribute_params.permit(
      :q,
      :resource_id,
      :country,
      :day,
      :month,
      :year,
      :as_of,
      :interactive_search,
      :request_id,
      :expanded_query,
      :current_question,
      :current_options,
      :experiment,
      answers: %i[question options answer],
      interactive_search_form: [:answer],
    ).to_h
      .merge(extract_search_date_parts)
      .merge(experiment: Current.experiment)
      .compact
  end

  def search_params
    search_attribute_params.permit(:q, :day, :month, :year).to_h.merge(extract_search_date_parts(search_attribute_params))
  end

  def quota_search_params
    params.permit(QuotaSearchForm::PERMITTED_PARAMS)
      .to_h
      .merge(extract_search_date_parts(quota_search_date_source))
  end

  def quota_search_date_source
    quota_search_params = params[:quota_search_form]

    quota_search_params.respond_to?(:permit) ? quota_search_params : params
  end

  def quota_search_date_redirect_required?
    params[:quota_search_form].present? &&
      extract_search_date_parts(quota_search_date_source).present? &&
      params.values_at(:day, :month, :year).any?(&:blank?)
  end

  def canonical_quota_search_query
    request.query_parameters
      .except('quota_search_form')
      .merge(extract_search_date_parts(quota_search_date_source))
  end
end
