class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include TradeTariffFrontend::ViewContext::Controller
  include ApplicationHelper
  include BasicSessionAuth
  include CacheHelper
  include TradeTariffFrontend::Config::RegisteredFlags

  include CacheControl
  include FlagsmithSetup
  include BotProtection
  include ErrorHandling

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
                :is_switch_service_banner_enabled?,
                :extract_search_date_parts

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
end
