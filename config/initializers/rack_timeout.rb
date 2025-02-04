Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: ENV.fetch('RACK_TIMEOUT_SERVICE_TIMEOUT', 5).to_i
