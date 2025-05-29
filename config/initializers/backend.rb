require 'client_builder'
require 'duty_calculator/client_builder'

Rails.application.config.http_client_uk = ClientBuilder.new('uk', cache: Rails.cache).call
Rails.application.config.http_client_xi = ClientBuilder.new('xi', cache: Rails.cache).call

api_options = ENV['API_SERVICE_BACKEND_URL_OPTIONS'] || '{}'

Rails.application.config.api_options = JSON.parse(api_options).symbolize_keys

if Rails.application.config.api_options.present?
  Rails.application.config.duty_calculator_http_client_uk = DutyCalculator::ClientBuilder.new(:uk).call
  Rails.application.config.duty_calculator_http_client_xi = DutyCalculator::ClientBuilder.new(:xi).call
end
