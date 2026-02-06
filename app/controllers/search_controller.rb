require 'addressable/uri'

class SearchController < ApplicationController
  include GoodsNomenclatureHelper
  include ClassicSearchable
  include InteractiveSearchable

  before_action :disable_switch_service_banner, only: [:quota_search]
  before_action :disable_search_form, except: [:search]

  def search
    @search.q = params[:q] if params[:q]
    @search.internal_search = params[:internal_search] == 'true'
    @search.answers = params[:answers] if params[:answers].present?
    @search.request_id = params[:request_id] if params[:request_id].present?

    if internal_search?
      perform_interactive_search
    else
      perform_classic_search
    end
  rescue Search::InvalidDate
    redirect_to find_commodity_path(search_params.merge(invalid_date: true))
  end

  def suggestions
    search_term = Regexp.escape(params[:term].to_s.strip)
    matched_suggestions = SearchSuggestion.all(q: search_term)
    results = matched_suggestions.map do |s|
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

  def internal_suggestions
    unless TradeTariffFrontend.internal_search_enabled?
      return suggestions
    end

    search_term = Regexp.escape(params[:term].to_s.strip)

    api_host = TradeTariffFrontend::ServiceChooser.api_host
    path = "#{URI.parse(api_host).path.sub(%r{/api\b}, '/internal')}/search_suggestions"

    response = TradeTariffFrontend::ServiceChooser.api_client.get(path, q: search_term)
    parsed = TariffJsonapiParser.new(response.body).parse
    parsed = [] unless parsed.is_a?(Array)

    matched_suggestions = parsed.map { |attrs| SearchSuggestion.new(attrs) }
    results = matched_suggestions.map do |s|
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

  def quota_search
    if TradeTariffFrontend::ServiceChooser.xi?
      raise TradeTariffFrontend::FeatureUnavailable
    end

    form = QuotaSearchForm.new(quota_search_params)
    @result = QuotaSearchPresenter.new(form)

    # Test the search date to check if it's valid
    @search.date unless params.key?(:invalid_date) && params[:invalid_date] == 'true'

    respond_to do |format|
      format.html
    end
  rescue Search::InvalidDate
    redirect_to quota_search_path(quota_search_params.merge(invalid_date: true))
  end

  def chemical_search
    form = ChemicalSearchForm.new(params.permit(:cas, :name, :page))
    @result = ChemicalSearchPresenter.new(form)

    respond_to do |format|
      format.html
    end
  end

  private

  def anchor
    params.dig(:search, :anchor).to_s.gsub(/[^a-zA-Z_-]/, '').presence
  end

  def missing_search_query_fallback_url
    return sections_path(anchor:) if request.referer.blank?

    back_url = URI(request.referer)
    if back_url.host.present? && back_url.host != request.host
      return sections_path(anchor:)
    end

    query_values = CGI.parse(back_url.query || '')
    query_values = query_values.transform_values { |v| v.many? ? v : v.first }
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
    params.fetch(:search, params).permit(
      :q,
      :resource_id,
      :country,
      :day,
      :month,
      :year,
      :as_of,
      :internal_search,
      :request_id,
      :current_question,
      :current_options,
      :skip_questions,
      answers: %i[question options answer],
      internal_search_form: [:answer],
    ).to_h
  end

  def search_params
    params.permit(:q, :day, :month, :year)
  end

  def quota_search_params
    params.permit(QuotaSearchForm::PERMITTED_PARAMS)
  end
end
