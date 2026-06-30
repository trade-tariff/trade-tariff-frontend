class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include TradeTariffFrontend::ViewContext::Controller
  include ApplicationHelper
  include BasicSessionAuth
  include CacheHelper

  before_action :maintenance_mode_if_active
  before_action :set_cache
  before_action :set_current_flagsmith_identity
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
  rescue_from Search::InvalidDate, with: :handle_invalid_search_date

  def url_options
    return super unless search_invoked?

    opt = {}
    opt.merge!(search_date_query_params) if @search&.day_month_and_year_set?
    opt.merge!(country: params[:country]) if params.key?(:country)
    opt.merge!(super)
  end

  private

  helper_method :cookies_policy,
                :meursing_lookup_result,
                :is_switch_service_banner_enabled?

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

  def search_invoked?
    params[:q].present? || search_attribute_params[:q].present? || params[:day].present? || params[:country].present?
  end

  def set_search
    @search ||= Search.new(search_attributes)
    @search.errors.add(:as_of, 'You must enter a valid date') if invalid_date_for_current_search?
  end

  def invalid_date_for_current_search?
    return false unless params[:invalid_date].present? && search_invoked?

    @search.date
    false
  rescue Search::InvalidDate
    true
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
    ).to_h.merge(extract_search_date_parts)
  end

  def search_attribute_params
    search_params = params[:search]

    search_params.respond_to?(:permit) ? search_params : params
  end

  def extract_search_date_parts(source = search_attribute_params)
    TariffDate.normalized_date_attributes(source)
  end

  def search_date_query_params
    {
      day: @search.day,
      month: @search.month,
      year: @search.year,
    }
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
    payload[:request_id] = request.request_id
    payload[:search_request_id] = @search&.request_id
    payload[:user_agent] = request.env['HTTP_USER_AGENT']
    payload.merge!(@handled_exception_log_context) if defined?(@handled_exception_log_context) && @handled_exception_log_context.present?
  end

  def set_path_info
    @path_info = { search_suggestions_path: search_suggestions_path(format: :json),
                   faq_send_feedback_path: green_lanes_send_feedback_path }

    if interactive_search_enabled?
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

  def flagsmith_feature_enabled?(flag)
    return false if Current.flagsmith_unavailable

    flags = Current.flagsmith_flags ||= FlagsmithClient.instance.get_flags_for(Current.flagsmith_identity)
    flags.is_feature_enabled(flag.to_s)
  rescue StandardError => e
    Current.flagsmith_unavailable = true
    Rails.logger.warn("Flagsmith unavailable, disabling #{flag}: #{e.class}: #{e.message}")
    false
  end

  def interactive_search_enabled?
    return false if TradeTariffFrontend::ServiceChooser.xi?

    flagsmith_feature_enabled?(:interactive_search)
  end

  def set_current_flagsmith_identity
    Current.flagsmith_identity = current_flagsmith_identity
  end

  def current_flagsmith_identity
    Flagsmith::AnonymousIdentity.new(anonymous_flagsmith_id)
  end

  def anonymous_flagsmith_id
    return cookies[:flagsmith_anonymous_id] if cookies[:flagsmith_anonymous_id].present?

    uuid = SecureRandom.uuid
    cookies[:flagsmith_anonymous_id] = {
      value: uuid,
      max_age: 1.year.to_i,
      httponly: true,
      secure: Rails.env.production?,
    }
    uuid
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

  def handle_invalid_search_date(exception)
    return bad_request(exception) unless request.get? && request.format.html?

    Rails.logger.info(exception.message)
    redirect_to invalid_date_redirect_options
  end

  def invalid_date_redirect_options
    request.path_parameters.except(:day, :month, :year, 'day', 'month', 'year').merge(
      request.query_parameters.except('day', 'month', 'year'),
      day: nil,
      month: nil,
      year: nil,
      invalid_date: true,
      only_path: true,
    )
  end

  def raise_internal_server_error(exception)
    @handled_exception_log_context = handled_exception_log_context(exception)
    NewRelic::Agent.notice_error(exception, custom_params: @handled_exception_log_context)
    Rails.logger.error(@handled_exception_log_context.to_json)
    redirect_to '/500', status: :internal_server_error
  end

  def handled_exception_log_context(exception)
    {
      exception_class: exception.class.name,
      exception_message: exception.message,
      search_request_id: @search&.request_id,
    }.merge(faraday_response_log_context(exception)).compact
  end

  def faraday_response_log_context(exception)
    response = exception.respond_to?(:response) ? exception.response : nil
    return {} unless response

    response = response[:response] || response['response'] || response
    body, body_truncated = truncated_backend_response_body(response[:body] || response['body'])

    {
      backend_status: response[:status] || response['status'],
      backend_url: (response[:url] || response['url'])&.to_s,
      backend_response_body: body,
      backend_response_body_truncated: body_truncated,
    }.compact
  end

  def truncated_backend_response_body(body)
    return [nil, nil] if body.nil?

    value = body.is_a?(String) ? body : body.to_json
    return [nil, nil] if value.blank?

    [value.first(500), value.length > 500]
  end

  alias_method :handle_connection_failed, :raise_internal_server_error
  alias_method :handle_timeout_error, :raise_internal_server_error
  alias_method :handle_server_error, :raise_internal_server_error
end
