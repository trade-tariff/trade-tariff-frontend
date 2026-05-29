require 'trade_tariff_frontend/service_timeout'

ENV['RACK_TIMEOUT_SERVICE_TIMEOUT'] ||= TradeTariffFrontend::ServiceTimeout::DEFAULT_TIMEOUT.to_s
ENV['RACK_TIMEOUT_PATH_OVERRIDES'] ||= TradeTariffFrontend::ServiceTimeout::DEFAULT_PATH_OVERRIDES

if defined?(Rack::Timeout)
  Rails.application.config.middleware.delete Rack::Timeout
end

Rails.application.config.middleware.insert_after(
  ActionDispatch::RequestId,
  TradeTariffFrontend::ServiceTimeout,
)
