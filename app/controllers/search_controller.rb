require 'addressable/uri'

class SearchController < ApplicationController
  include GoodsNomenclatureHelper
  include ClassicSearchable
  include InteractiveSearchable
  include HybridSearchable

  skip_before_action :verify_authenticity_token, only: [:search]

  before_action :disable_switch_service_banner, only: [:quota_search]
  before_action :disable_search_form, except: [:search]

  def search
    params[:q] = search_attribute_params[:q] if params[:q].blank? && search_attribute_params[:q].present?

    @search.q = params[:q] if params[:q]
    @search.interactive_search = params[:interactive_search] == 'true'
    @search.answers = params[:answers] if params[:answers].present?
    @search.request_id = params[:request_id].presence || SecureRandom.uuid
    @search.expanded_query = params[:expanded_query].presence

    if interactive_search?
      perform_interactive_search
    elsif hybrid_search?
      perform_hybrid_search
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
      answers: %i[question options answer],
      interactive_search_form: [:answer],
    ).to_h.merge(extract_search_date_parts)
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
