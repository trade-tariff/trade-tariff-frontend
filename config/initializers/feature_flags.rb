Unleash.configure do |config|
  config.app_name            = 'ott-frontend'
  config.url                 = 'http://localhost:4242/api'
  config.logger              = Rails.logger
  config.custom_http_headers = { 'Authorization': 'default:development.unleash-insecure-api-token' }
end

FeatureService = Unleash::Client.new
