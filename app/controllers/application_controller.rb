require 'api_entity'

class ApplicationController < ActionController::Base
  protect_from_forgery
  include TradeTariffFrontend::ViewContext::Controller
  include ApplicationHelper
  include CookiesHelper

  before_action :set_cache
  before_action :set_enable_service_switch_banner_in_action
  before_action :set_last_updated
  before_action :set_path_info

  before_action :set_search
  before_action :maintenance_mode_if_active
  before_action :bots_no_index_if_historical

  layout :set_layout

  rescue_from ApiEntity::Error, Errno::ECONNREFUSED do
    request.format = :html
    render_500
  end

  rescue_from(ApiEntity::NotFound, ActionView::MissingTemplate, ActionController::UnknownFormat,
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

  def render_500
    @no_shared_search = true
    render template: 'errors/internal_server_error',
           status: :internal_server_error,
           formats: :html
    false
  end

  def render_404
    @no_shared_search = true
    render template: 'errors/not_found',
           status: :not_found,
           formats: :html
    false
  end

  def set_last_updated
    @tariff_last_updated ||= TariffUpdate.latest_applied_import_date
  end

  def set_enable_service_switch_banner_in_action
    @enable_service_switch_banner_in_action = true
  end

  def search_invoked?
    params[:q].present? || params[:day].present? || params[:country].present?
  end

  def set_search
    @search ||= Search.new(search_attributes)
  end

  def search_attributes
    params.permit!.to_h
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
    expires_now
  end

  def cookies_policy
    @cookies_policy ||= Cookies::Policy.from_cookie(cookies[:cookies_policy])
  end
  helper_method :cookies_policy

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
