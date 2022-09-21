module Retriable
  def with_retries(*rescue_errors)
    retries ||= 0
    rescue_errors = [StandardError] if rescue_errors.empty?

    yield if block_given?
  rescue *rescue_errors
    if retries < Rails.configuration.x.http.max_retry
      retries += 1
      retry
    else
      raise
    end
  end
end
