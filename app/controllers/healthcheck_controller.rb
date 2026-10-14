class HealthcheckController < ApplicationController
  # ApplicationController callbacks must not run here. They add forgery checks,
  # maintenance mode, cache headers, Flagsmith, search, and bot handling.
  # Included modules add further callbacks. Skip the inherited chain instead of
  # copying those filters.
  _process_action_callbacks.dup.each do |callback|
    skip_callback(:process_action, callback.kind, callback.filter)
  end

  rescue_from Faraday::ServerError do |_e|
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

  def original_ua_headers
    { 'X_ORIGINAL_USER_AGENT' => request.env['HTTP_USER_AGENT'] }
  end
end
