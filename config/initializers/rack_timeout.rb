ENV['RACK_TIMEOUT_SERVICE_TIMEOUT'] ||= '15'

require 'trade_tariff_frontend/service_timeout'

if defined?(Rack::Timeout)
  Rails.application.config.middleware.delete Rack::Timeout
end

Rails.application.config.middleware.insert_after(
  ActionDispatch::RequestId,
  TradeTariffFrontend::ServiceTimeout,
)
