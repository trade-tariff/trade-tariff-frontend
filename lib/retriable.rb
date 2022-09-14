module Retriable
  def retries(*rescue_errors)
    retries ||= 0
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
