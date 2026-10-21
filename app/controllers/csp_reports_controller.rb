class CspReportsController < ApplicationController
  # A CSP report is a few hundred bytes. Read no more than this, so that a
  # large body cannot fill the logs.
  MAX_REPORT_BYTES = 4096

  skip_before_action :require_authentication, only: %i[create]
  skip_forgery_protection only: %i[create]

  # Browsers send these reports in the background, so they are not
  # application errors. Log them only: as New Relic errors they were almost
  # all of the frontend's errors, and real errors were hard to see.
  def create
    report = request.body.read(MAX_REPORT_BYTES)
    Rails.logger.warn "CSP Violation: #{report}"
    head :ok
  end
end
