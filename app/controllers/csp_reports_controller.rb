class CspReportsController < ApplicationController
  skip_before_action :require_authentication, only: %i[create]
  skip_forgery_protection only: %i[create]
  def create
    Rails.logger.warn "CSP Violation: #{request.body.read}"
    NewRelic::Agent.notice_error("CSP Violation: #{request.body.read}")
    head :ok
  end
end
