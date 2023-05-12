class ErrorsController < ApplicationController
  skip_before_action :maintenance_mode_if_active
  skip_before_action :set_last_updated
  skip_before_action :set_path_info
  skip_before_action :set_search
  skip_before_action :bots_no_index_if_historical
  skip_after_action :gc_session_data

  before_action :disable_search_form, :disable_switch_service_banner

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: 'Resource not found' }, status: :not_found }
      format.all { render status: :not_found, plain: 'Resource not found' }
    end
  end

  def internal_server_error
    @skip_news_banner = true

    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json { render json: { error: 'Internal server error' }, status: :internal_server_error }
      format.all { render status: :internal_server_error, plain: 'Internal server error' }
    end
  end

  def maintenance
    @skip_news_banner = true

    respond_to do |format|
      format.html { render status: :service_unavailable }
      format.json { render json: { error: 'Maintenance mode' }, status: :service_unavailable }
      format.all { render status: :service_unavailable, plain: 'Maintenance mode' }
    end
  end

  def search_invoked?
    false
  end
end
