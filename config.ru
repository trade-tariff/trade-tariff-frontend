# This file is used by Rack-based servers to start the application.

# rubocop:disable Style/ExpandPathArguments
require ::File.expand_path('../config/environment', __FILE__)
# rubocop:enable Style/ExpandPathArguments

run TradeTariffFrontend::Application
