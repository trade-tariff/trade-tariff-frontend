class CspReportsController < ApplicationController
  skip_before_action :require_authentication, only: %i[create]
  skip_forgery_protection only: %i[create]
  def create
    violation_body = request.body.read
    Rails.logger.warn "CSP Violation: #{violation_body}"

    unless gtm_csp_violation?(violation_body)
      NewRelic::Agent.notice_error("CSP Violation: #{violation_body}")
    end

    head :ok
  end

private

  def gtm_csp_violation?(violation_body)
    violation_body.include?('Content Security Policy') && violation_body.include?('googletagmanager')
  end
end
