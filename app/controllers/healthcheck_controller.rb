require 'api_entity'
# rubocop:disable Rails/ApplicationController
class HealthcheckController < ActionController::Base
  # rubocop:enable Rails/ApplicationController
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
