require "api_entity"

class ApplicationController < ActionController::Base
  protect_from_forgery
  include TradeTariffFrontend::ViewContext::Controller
  include ApplicationHelper

  before_action :sample_requests_for_scout
  before_action :set_last_updated
  before_action :set_cache
  before_action :preprocess_raw_params
  before_action :search_query
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

    if search_query.date.today? || search_query.date == TradeTariffFrontend.simulation_date
      return { country: search_query.country, currency: search_query.currency }.merge(super)
    end

    {
      year: search_query.date.year,
      month: search_query.date.month,
      day: search_query.date.day,
      country: search_query.country,
      currency: search_query.currency
    }.merge(super)
  end

  private

  def render_500
    @no_shared_search = true
    render template: "errors/internal_server_error",
           status: :internal_server_error,
           formats: :html
    false
  end

  def render_404
    @no_shared_search = true
    render template: "errors/not_found",
           status: :not_found,
           formats: :html
    false
  end

  def set_last_updated
    @tariff_last_updated ||= TariffUpdate.latest_applied_import_date
  end

  def search_invoked?
    params[:q].present? || params[:day].present? || params[:country].present?
  end

  def search_query
    @search ||= Search.new(params.permit!.to_h)
  end

  def set_layout
    if request.headers['X-AJAX']
      false
    else
      "application"
    end
  end

  def query_params
    { as_of: search_query.date, currency: search_query.currency }
  end

  def set_cache
    unless Rails.env.development?
      expires_in 2.hours, :public => true, 'stale-if-error' => 86_400, 'stale-while-revalidate' => 86_400
    end
  end

  protected

  def preprocess_raw_params
    if TradeTariffFrontend.block_searching_past_brexit? && params[:year] && params[:month] && params[:day]
      now = Date.current
      search_date = begin
        Date.new(*[params[:year], params[:month], params[:day]].map(&:to_i))
      rescue ArgumentError
        now
      end
      brexit_date = Date.parse(ENV['BREXIT_DATE'] || '2021-01-01')
      if (search_date >= brexit_date) && (now < brexit_date)
        params[:year] = now.year
        params[:month] = now.month
        params[:day] = now.day
        flash[:alert] = "Sorry we are currently unable to display data past #{brexit_date.strftime("#{brexit_date.day.ordinalize} of %B %Y")}"
      end
    end
  end

  def maintenance_mode_if_active
    if ENV["MAINTENANCE"].present? && action_name != "maintenance"
      redirect_to "/503"
    end
  end

  def bots_no_index_if_historical
    return if search_query.today?

    response.headers["X-Robots-Tag"] = "none"
  end

  def append_info_to_payload(payload)
    super
    payload[:user_agent] = request.env["HTTP_USER_AGENT"]
  end

  def sample_requests_for_scout
    # Sample rate should range from 0-1:
    # * 0: captures no requests
    # * 0.75: captures 75% of requests
    # * 1: captures all requests
    sample_rate = 0.1

    if rand > sample_rate
      Rails.logger.debug("[Scout] Ignoring request: #{request.original_url}")
      ScoutApm::Transaction.ignore!
    end
  end
end
