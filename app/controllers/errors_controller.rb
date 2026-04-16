class ErrorsController < ApplicationController
  skip_before_action :maintenance_mode_if_active
  skip_before_action :set_path_info
  skip_before_action :set_search
  skip_before_action :bots_no_index_if_historical

  before_action :disable_search_form,
                :disable_switch_service_banner,
                :skip_news_banner

  ERROR_RESPONSES = {
    unprocessable_content: {
      message: "We're sorry, but we cannot process your request at this time.<br>
               Please contact support for assistance or try a different request.".html_safe,
    },
    internal_server_error: {
      header: 'We are experiencing technical difficulties',
      message: 'We are experiencing technical difficulties',
    },
    bad_request: {
      message: "The request you made is not valid.<br>
               Please contact support for assistance or try a different request.".html_safe,
    },
    method_not_allowed: {
      message: "We're sorry, but this request method is not supported.<br>
               Please contact support for assistance or try a different request.".html_safe,
    },
    not_acceptable: {
      message: "Unfortunately, we cannot fulfill your request as it is not in a format we can accept.<br>
               Please contact support for assistance or try a different request.".html_safe,
    },
    not_implemented: {
      message: "We're sorry, but the requested action is not supported by our server at this time.<br>
               Please contact support for assistance or try a different request.".html_safe,
    },
    too_many_requests: {
      message: 'You are rate limited. Please try again later.',
    },
  }.freeze

  ERROR_RESPONSES.each_key do |action|
    define_method(action) { render_error(status: action, **ERROR_RESPONSES[action]) }
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

  def render_error(status:, message:, header: nil, json_error: nil)
    header ||= status.to_s.humanize
    json_error ||= status.to_s.humanize

    respond_to do |format|
      format.html { render 'error', status:, locals: { header:, message: } }
      format.json { render json: { error: json_error }, status: }
      format.all { render status:, plain: json_error }
    end
  end
end
