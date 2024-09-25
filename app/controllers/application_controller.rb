require 'api_entity'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include TradeTariffFrontend::ViewContext::Controller
  include ApplicationHelper

  before_action :maintenance_mode_if_active

  before_action :set_cache
  before_action :set_last_updated
  before_action :set_path_info
  before_action :set_search
  before_action :bots_no_index_if_historical

  layout :set_layout

  private

  helper_method :cookies_policy,
                :meursing_lookup_result,
                :is_switch_service_banner_enabled?

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
    @path_info = { search_suggestions_path: search_suggestions_path(format: :json) }
  end

  def country
    params['country'].try(:upcase)
  end

  def check_green_lanes_enabled
    unless TradeTariffFrontend.green_lanes_enabled?
      raise TradeTariffFrontend::FeatureUnavailable
    end
  end
end
