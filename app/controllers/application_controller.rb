require 'api_entity'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include TradeTariffFrontend::ViewContext::Controller
  include ApplicationHelper

  before_action :set_cache
  before_action :set_last_updated
  before_action :set_path_info

  before_action :set_search
  before_action :maintenance_mode_if_active
  before_action :bots_no_index_if_historical

  layout :set_layout

  rescue_from ApiEntity::Error, Faraday::ServerError, Errno::ECONNREFUSED do
    request.format = :html
    render_500
  end

  rescue_from(Faraday::ResourceNotFound,
              ActionView::MissingTemplate, ActionController::UnknownFormat,
              AbstractController::ActionNotFound, URI::InvalidURIError) do |_e|
    request.format = :html
    render_404
  end

  def url_options
    return super unless search_invoked?

    set_search

    if @search.date.today?
      return { country: @search.country }.merge(super)
    end

    {
      year: @search.date.year,
      month: @search.date.month,
      day: @search.date.day,
      country: @search.country,
    }.merge(super)
  end

  private

  helper_method :cookies_policy,
                :meursing_lookup_result,
                :is_switch_service_banner_enabled?

  def render_500
    disable_search_form
    render template: 'errors/internal_server_error',
           status: :internal_server_error,
           formats: :html
    false
  end

  def render_404
    disable_search_form
    render template: 'errors/not_found',
           status: :not_found,
           formats: :html
    false
  end

  def set_last_updated
    # rubocop:disable Naming/MemoizedInstanceVariableName
    @tariff_last_updated ||= TariffUpdate.latest_applied_import_date
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end

  def disable_switch_service_banner!
    @disable_switch_service_banner = true
  end

  def is_switch_service_banner_enabled?
    !@disable_switch_service_banner
  end

  def disable_search_form
    @no_shared_search = true
  end

  def search_invoked?
    params[:q].present? || params[:day].present? || params[:country].present?
  end

  def set_search
    # rubocop:disable Naming/MemoizedInstanceVariableName
    @search ||= Search.new(search_attributes)
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end

  def search_attributes
    params.permit(
      :q,
      :country,
      :day,
      :month,
      :year,
      :as_of,
    ).to_h
  end

  def set_layout
    if request.headers['X-AJAX']
      false
    else
      'application'
    end
  end

  def query_params
    { as_of: @search.date }
  end

  def set_cache
    response.headers['Cache-Control'] = 'public, must-revalidate, proxy-revalidate, max-age=0'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '-1'
  end

  def cookies_policy
    @cookies_policy ||= Cookies::Policy.from_cookie(cookies[:cookies_policy])
  end

  def meursing_lookup_result
    @meursing_lookup_result ||= MeursingLookup::Result.new(meursing_additional_code_id: session[MeursingLookup::Result::CURRENT_MEURSING_ADDITIONAL_CODE_KEY])
  end

  protected

  def maintenance_mode_if_active
    if ENV['MAINTENANCE'].present? && action_name != 'maintenance'
      redirect_to '/503'
    end
  end

  def bots_no_index_if_historical
    return if @search.today?

    response.headers['X-Robots-Tag'] = 'none'
  end

  def append_info_to_payload(payload)
    super
    payload[:user_agent] = request.env['HTTP_USER_AGENT']
  end

  def set_path_info
    @path_info = {
      geographical_areas_path: geographical_areas_path(format: :json),
      search_suggestions_path: search_suggestions_path(format: :json),
    }
  end
end
