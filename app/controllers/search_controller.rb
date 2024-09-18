require 'addressable/uri'

class SearchController < ApplicationController
  BETA_POSSIBLE_FILTERS = %w[
    alcohol_volume
    animal_product_state
    animal_type
    art_form
    battery_charge
    battery_grade
    battery_type
    beverage_type
    bone_state
    bovine_age_gender
    bread_type
    brix_value
    cable_type
    car_capacity
    car_type
    cereal_state
    cheese_type
    clothing_fabrication
    clothing_gender
    cocoa_state
    coffee_state
    computer_type
    dairy_form
    egg_purpose
    egg_shell_state
    electrical_output
    electricity_type
    entity
    fat_content
    fish_classification
    fish_preparation
    flour_source
    fruit_spirit
    fruit_vegetable_state
    fruit_vegetable_type
    garment_material
    garment_type
    glass_form
    glass_purpose
    height
    herb_spice_state
    ingredient
    jam_sugar_content
    jewellery_type
    length
    margarine_state
    material
    metal_type
    metal_usage
    monitor_connectivity
    monitor_type
    mounting
    new_used
    nut_state
    oil_fat_source
    pasta_state
    plant_state
    precious_stone
    product_age
    pump_type
    purpose
    sugar_state
    template
    tobacco_type
    vacuum_type
    weight
    wine_origin
    wine_type
    yeast_state
    chapter_id
    heading_id
    producline_suffix
    goods_nomenclature_class
  ].freeze

  include GoodsNomenclatureHelper

  before_action :disable_switch_service_banner, only: [:quota_search]
  before_action :disable_search_form, except: [:search]

  def search
    if beta_search_enabled?
      perform_beta_search
    else
      perform_legacy_search
    end
  rescue Search::InvalidDate
    redirect_to find_commodity_path(search_params.merge(invalid_date: true))
  end

  def toggle_beta_search
    session[:beta_search_enabled] = !session[:beta_search_enabled]

    redirect_back fallback_location: find_commodity_path
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

    form = QuotaSearchForm.new(params.permit(*QuotaSearchForm::PERMITTED_PARAMS))
    @result = QuotaSearchPresenter.new(form)

    # Test the search date to check if it's valid
    @search.date unless params.key?(:invalid_date)

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

  def url_options
    return super unless search_invoked?

    opt = {}
    opt.merge!(day: params[:day]) if params.key?(:day)
    opt.merge!(month: params[:month]) if params.key?(:month)
    opt.merge!(year: params[:year]) if params.key?(:year)
    opt.merge!(country: params[:country]) if params.key?(:country)
    opt.merge!(super)
  end

  private

  def perform_legacy_search
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
  end

  def perform_beta_search
    @search_result = Beta::Search::PerformSearchService.new(beta_query_options, beta_filters).call
    @query = params[:q]
    @filters = beta_filters

    return redirect_to polymorphic_path(@search_result.direct_hit) if @search_result.direct_hit.present?

    render 'beta/search_results/show'
  end

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
    if @search.date.today?
      back_url.query_values = back_url.query_values.except('year', 'month', 'day')
    end
    back_url.fragment = anchor

    back_url.to_s
  end

  def beta_query_options
    options = {}
    options[:resource_id] = beta_resource_id if beta_resource_id.present?
    options[:spell] = beta_spell
    options[:q] = beta_query
    options
  end

  def beta_query
    @beta_query ||= beta_search_params[:q].presence || ''
  end

  def beta_spell
    beta_search_params[:spell].presence || '1'
  end

  def beta_resource_id
    beta_search_params[:resource_id].presence
  end

  def beta_filters
    @beta_filters ||= params[:filter]&.permit(*BETA_POSSIBLE_FILTERS).to_h || {}
  end

  def beta_search_params
    @beta_search_params ||= params.permit(:q, :filters, :spell, :resource_id)
  end

  def search_params
    params.permit(:q, :day, :month, :year)
  end

  def quota_search_params
    params.permit(:day, :month, :year, :order_number, :goods_nomenclature_item_id, :geographical_area_id, :critical, :status)
  end
end
