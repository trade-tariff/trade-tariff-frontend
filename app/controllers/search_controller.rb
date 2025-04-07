require 'addressable/uri'

class SearchController < ApplicationController
  include GoodsNomenclatureHelper

  before_action :disable_switch_service_banner, only: [:quota_search]
  before_action :disable_search_form, except: [:search]

  def search
    @search.q = params[:q] if params[:q]

    @results = @search.perform

    respond_to do |format|
      format.html do
        if @search.missing_search_term?
          redirect_to missing_search_query_fallback_url
        elsif @results.exact_match?
          redirect_to url_for @results.to_param.merge(url_options).merge(only_path: true)
        elsif @results.none? && @search.search_term_is_commodity_code?
          redirect_to commodity_path(@search.q)
        elsif @results.none? && @search.search_term_is_heading_code?
          redirect_to heading_path(@search.q)
        end
      end

      format.json do
        render json: SearchPresenter.new(@search, @results)
      end

      format.atom
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

    back_url = Addressable::URI.parse(request.referer)
    if back_url.host.present? && back_url.host != request.host
      return sections_path(anchor:)
    end

    back_url.query_values ||= {}
    back_url.query_values = back_url.query_values.merge(@search.query_attributes)
    back_url.query_values = back_url.query_values.tap { |qv| qv.delete('invalid_date') }
    if @search.date.today?
      back_url.query_values = back_url.query_values.except('year', 'month', 'day')
    end
    back_url.fragment = anchor
    back_url.to_s
  end

  def search_params
    params.permit(:q, :day, :month, :year)
  end

  def quota_search_params
    params.permit(QuotaSearchForm::PERMITTED_PARAMS)
  end
end
