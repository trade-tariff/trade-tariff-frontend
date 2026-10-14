class HealthcheckController < ApplicationController
  # ApplicationController callbacks must not run here. They add forgery checks,
  # maintenance mode, cache headers, Flagsmith, search, and bot handling.
  # Included modules add further callbacks. Skip the inherited chain instead of
  # copying those filters.
  _process_action_callbacks.dup.each do |callback|
    skip_callback(:process_action, callback.kind, callback.filter)
  end

  # Drop inherited page error handlers. A copied list keeps ApplicationController unchanged.
  self.rescue_handlers = rescue_handlers.dup.clear

  rescue_from Faraday::ServerError,
              Faraday::ConnectionFailed,
              Faraday::TimeoutError,
              Faraday::TooManyRequestsError do |_error|
    render plain: '', status: :internal_server_error
  end

  def check
    NewRelic::Agent.ignore_transaction
    # Check API connectivity
    Section.all(headers: original_ua_headers)
    render json: { git_sha1: CURRENT_REVISION }
  end

  def checkz
    NewRelic::Agent.ignore_transaction
    render json: { git_sha1: CURRENT_REVISION }
  end

  private

  # The application logger writes a guided-search session id. Probes must not.
  def append_info_to_payload(payload)
    ApplicationController.instance_method(:append_info_to_payload).super_method.bind_call(self, payload)
  end

  def original_ua_headers
    { 'X_ORIGINAL_USER_AGENT' => request.env['HTTP_USER_AGENT'] }
  end
end
