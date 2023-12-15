class ErrorsController < ApplicationController
  skip_before_action :maintenance_mode_if_active
  skip_before_action :set_last_updated
  skip_before_action :set_path_info
  skip_before_action :set_search
  skip_before_action :bots_no_index_if_historical

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
    # shouldn't this be service_unavailable as that's what exception is mapped to
    # 'TradeTariffFrontend::MaintenanceMode' => :service_unavailable,
    @skip_news_banner = true

    respond_to do |format|
      format.html { render status: :service_unavailable }
      format.json { render json: { error: 'Maintenance mode' }, status: :service_unavailable }
      format.all { render status: :service_unavailable, plain: 'Maintenance mode' }
    end
  end

  def unprocessable_entity
    @skip_news_banner = true

    respond_to do |format|
      format.html { render status: :unprocessable_entity }
      format.json { render json: { error: 'Unprocessable entity' }, status: :unprocessable_entity }
      format.all { render status: :unprocessable_entity, plain: 'Unprocessable entity' }
    end
  end

  def bad_request
    @skip_news_banner = true

    respond_to do |format|
      format.html { render status: :bad_request }
      format.json { render json: { error: 'Bad request' }, status: :bad_request }
      format.all { render status: :bad_request, plain: 'Bad request' }
    end
  end

  def not_implemented
    internal_server_error
  end

  def method_not_allowed
    internal_server_error
  end

  def not_acceptable
    internal_server_error
  end

  def search_invoked?
    false
  end
end
