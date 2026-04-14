class ErrorsController < ApplicationController
  skip_before_action :maintenance_mode_if_active
  skip_before_action :set_path_info
  skip_before_action :set_search
  skip_before_action :bots_no_index_if_historical

  before_action :disable_search_form,
                :disable_switch_service_banner,
                :skip_news_banner

  ERROR_RESPONSES = {
    unprocessable_entity: {
      status: :unprocessable_entity,
      header: 'Unprocessable entity',
      message: "We're sorry, but we cannot process your request at this time.<br>
               Please contact support for assistance or try a different request.",
      html_safe: true,
      json_error: 'Unprocessable entity',
    },
    internal_server_error: {
      status: :internal_server_error,
      header: 'We are experiencing technical difficulties',
      message: 'We are experiencing technical difficulties',
      json_error: 'Internal server error',
    },
    bad_request: {
      status: :bad_request,
      header: 'Bad request',
      message: "The request you made is not valid.<br>
               Please contact support for assistance or try a different request.",
      html_safe: true,
      json_error: 'Bad request',
    },
    method_not_allowed: {
      status: :method_not_allowed,
      header: 'Method not allowed',
      message: "We're sorry, but this request method is not supported.<br>
               Please contact support for assistance or try a different request.",
      html_safe: true,
      json_error: 'Method not allowed',
    },
    not_acceptable: {
      status: :not_acceptable,
      header: 'Not acceptable',
      message: "Unfortunately, we cannot fulfill your request as it is not in a format we can accept.<br>
               Please contact support for assistance or try a different request.",
      html_safe: true,
      json_error: 'Not acceptable',
    },
    not_implemented: {
      status: :not_implemented,
      header: 'Not implemented',
      message: "We're sorry, but the requested action is not supported by our server at this time.<br>
               Please contact support for assistance or try a different request.",
      html_safe: true,
      json_error: 'Not implemented',
    },
    too_many_requests: {
      status: :too_many_requests,
      header: 'Too Many Requests',
      message: 'You are rate limited. Please try again later.',
      json_error: 'Too many requests',
    },
  }.freeze

  ERROR_RESPONSES.each_key do |action|
    define_method(action) { render_error(**ERROR_RESPONSES[action]) }
  end

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: 'Resource not found' }, status: :not_found }
      format.all { render status: :not_found, plain: 'Resource not found' }
    end
  end

  def maintenance
    respond_to do |format|
      format.html { render status: :service_unavailable }
      format.json { render json: { error: 'Maintenance mode' }, status: :service_unavailable }
      format.all { render status: :service_unavailable, plain: 'Maintenance mode' }
    end
  end

  def search_invoked?
    false
  end

  private

  def render_error(status:, header:, message:, json_error:, html_safe: false)
    message = message.html_safe if html_safe

    respond_to do |format|
      format.html { render 'error', status:, locals: { header:, message: } }
      format.json { render json: { error: json_error }, status: }
      format.all { render status:, plain: json_error }
    end
  end
end
