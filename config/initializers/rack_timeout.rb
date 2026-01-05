# Rack Timeout Configuration
# See: https://github.com/zombocom/rack-timeout
#
# RACK_TIMEOUT_SERVICE_TIMEOUT (seconds, default: 15)
# Maximum time the application can take to process and respond to a request once received.
# Requests exceeding this will be terminated (SIGTERM sent to worker).
# Current setting: 15 seconds (same as default).
ENV['RACK_TIMEOUT_SERVICE_TIMEOUT'] ||= '15'

# Other available settings (using defaults if not set):
# - RACK_TIMEOUT_WAIT_TIMEOUT: Maximum wait time in the web server queue (default: 30)
# - RACK_TIMEOUT_WAIT_OVERTIME: Additional wait time for requests with a body (POST, PUT, etc.) (default: 60)
# - RACK_TIMEOUT_SERVICE_PAST_WAIT: Whether to use full service_timeout even after wait_timeout (default: false)
# - RACK_TIMEOUT_TERM_ON_TIMEOUT: Send SIGTERM when timeout occurs (default: 0/false)
