require 'api_entity'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ApplicationHelper
  include BasicSessionAuth
  include CacheHelper
  include TradeTariffFrontend::ViewContext::Controller

  before_action :maintenance_mode_if_active
  before_action :set_cache
  before_action :set_last_updated
  before_action :set_path_info
  before_action :set_search
  before_action :bots_no_index_if_historical

  layout :set_layout

  rescue_from Faraday::TooManyRequestsError, with: :handle_too_many_requests_error
  rescue_from URI::InvalidURIError, with: :handle_invalid_uri_error
  rescue_from ActionController::UnknownFormat, with: :handle_unknown_format
  rescue_from Faraday::ConnectionFailed, with: :handle_connection_failed
  rescue_from Faraday::TimeoutError, with: :handle_timeout_error
  rescue_from Faraday::ServerError, with: :handle_server_error
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :handle_params_parse_error

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

  helper_method :cookies_policy,
                :meursing_lookup_result,
                :is_switch_service_banner_enabled?,
                :feature_enabled?,
                :session_identifier

  def session_identifier
    # At some point this may well become a user ID when behind auth
    request.session['id'] ||= SecureRandom.uuid
  end

  def set_last_updated
    # rubocop:disable Naming/MemoizedInstanceVariableName
    @tariff_last_updated ||= TariffUpdate.latest_applied_import_date
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end

  def disable_switch_service_banner
    @disable_switch_service_banner = true
  end

  def is_switch_service_banner_enabled?
    !@disable_switch_service_banner
  end

  def disable_search_form
    @no_shared_search = true
  end

  def skip_news_banner
    @skip_news_banner = true
  end

  def disable_last_updated_footnote
    @tariff_last_updated = nil
  end

  def search_invoked?
    params[:q].present? || params[:day].present? || params[:country].present?
  end

  def set_search
    @search ||= Search.new(search_attributes) # rubocop:disable Naming/MemoizedInstanceVariableName
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

  def meursing_lookup_result
    @meursing_lookup_result ||= MeursingLookup::Result.new(meursing_additional_code_id: session[MeursingLookup::Result::CURRENT_MEURSING_ADDITIONAL_CODE_KEY])
  end

  protected

  def maintenance_mode_if_active
    if ENV['MAINTENANCE'].present? && !maintenance_mode_bypass?
      raise TradeTariffFrontend::MaintenanceMode
    end
  end

  def maintenance_mode_bypass?
    ENV['MAINTENANCE_BYPASS'].present? && ENV['MAINTENANCE_BYPASS'] == params[:maintenance_bypass]
  end

  def bots_no_index_if_historical
    return if @search.today?

    response.headers['X-Robots-Tag'] = 'none'
  rescue StandardError
    response.headers['X-Robots-Tag'] = 'none'
  end

  def append_info_to_payload(payload)
    super
    payload[:user_agent] = request.env['HTTP_USER_AGENT']
  end

  def set_path_info
    @path_info = { search_suggestions_path: search_suggestions_path(format: :json),
                   faq_send_feedback_path: green_lanes_send_feedback_path }

    if TradeTariffFrontend.interactive_search_enabled?
      @path_info[:interactive_search_suggestions_path] = interactive_search_suggestions_path(format: :json)
    end
  end

  def country
    params['country'].try(:upcase)
  end

  def check_green_lanes_enabled
    unless TradeTariffFrontend.green_lanes_enabled?
      raise TradeTariffFrontend::FeatureUnavailable
    end
  end

  def handle_too_many_requests_error
    redirect_to '/429'
  end

  # Methods below are used to handle errors and
  # exceptions as we principally don't need these ending up in our error logging
  def raise_not_found(exception)
    Rails.logger.info(exception.message)
    redirect_to '/404', status: :not_found
  end

  alias_method :handle_invalid_uri_error, :raise_not_found
  alias_method :handle_unknown_format, :raise_not_found

  def bad_request(exception)
    Rails.logger.info(exception.message)
    redirect_to '/400', status: :bad_request
  end

  alias_method :handle_params_parse_error, :bad_request

  def raise_internal_server_error(exception)
    NewRelic::Agent.notice_error(exception)
    Rails.logger.error(exception.message)
    redirect_to '/500', status: :internal_server_error
  end

  alias_method :handle_connection_failed, :raise_internal_server_error
  alias_method :handle_timeout_error, :raise_internal_server_error
  alias_method :handle_server_error, :raise_internal_server_error
end
