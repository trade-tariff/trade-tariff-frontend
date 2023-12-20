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

  # issue: this one is not handled by the controller 
  def unprocessable_entity
    @skip_news_banner = true

    respond_to do |format|
      format.html { render status: :unprocessable_entity }
      format.json { render json: { error: 'Unprocessable entity' }, status: :unprocessable_entity }
      format.all { render status: :unprocessable_entity, plain: 'Unprocessable entity' }
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

  def bad_request # 400
    @skip_news_banner = true

    respond_to do |format|
      format.html { render status: :bad_request }
      format.json { render json: { error: 'Bad request' }, status: :bad_request }
      format.all { render status: :bad_request, plain: 'Bad request' }
    end
  end

  def method_not_allowed # 405
    binding.pry
    @skip_news_banner = true

    # message for method not allowed
    message = 'We\'re sorry, but this request method is not supported.<br>
               Please contact support for assistance or try a different request.'.html_safe

    respond_to do |format|
      format.html { render 'error', status: :method_not_allowed, locals: { header: 'Method not allowed', message: message } }
      format.json { render json: { error: 'Method not allowed' }, status: :method_not_allowed }
      format.all { render status: :method_not_allowed, plain: 'Method not allowed' }
    end
  end

  def not_acceptable # 406
    @skip_news_banner = true

    message = 'Unfortunately, we cannot fulfill your request as it\'s not in a format we can accept.<br>
               Please contact support for assistance or try a different request.'.html_safe

    respond_to do |format|
      format.html { render 'error', status: :not_acceptable, locals: { header: 'Not acceptable', message: message } }
      format.json { render json: { error: 'Not acceptable' }, status: :not_acceptable }
      format.all { render status: :not_acceptable, plain: 'Not acceptable' }
    end
  end

  def not_implemented # 501
    @skip_news_banner = true

    message = 'We\'re sorry, but the requested action is not supported by our server at this time.<br>
               Please contact support for assistance or try a different request.'.html_safe

    respond_to do |format|
      format.html { render 'error' , status: :not_implemented, locals: { header: 'Not implemented', message: message } }
      format.json { render json: { error: 'Not implemented' }, status: :not_implemented }
      format.all { render status: :not_implemented, plain: 'Not implemented' }
    end
  end

  def maintenance # 503
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
