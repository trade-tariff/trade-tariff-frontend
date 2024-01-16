require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
# require "active_job/railtie"

require 'active_record/attribute_assignment'
# require "active_record/railtie"
# require "active_storage/engine"
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

APP_SLUG = 'trade-tariff'.freeze

module TradeTariffFrontend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.time_zone = 'UTC'
    require 'trade_tariff_frontend'

    # Custom directories with classes and modules you want to be autoloadable.
    config.eager_load_paths += %W[
      #{config.root}/app/models/concerns
      #{config.root}/app/presenters
      #{config.root}/app/serializers
      #{config.root}/app/forms
    ]

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins ENV['CORS_HOST'] || '*'
        resource '*',
                 headers: :any,
                 methods: %i[get options]
      end
    end

    # Disable Rack::Cache.
    config.action_dispatch.rack_cache = nil

    # Tells Rails to serve error pages from the app itself, rather than using static error pages in public/
    config.exceptions_app = routes

    # Trade Tariff Backend API Version
    config.x.backend.api_version = ENV['TARIFF_API_VERSION'] || 1

    config.grouped_measure_types = config_for(:grouped_measure_types)

    config.x.http.retry_options = {}

    config.guide_links = config_for(:guide_links)
    # Prevent invalid queries from causing an error, e.g., `/api/v2/search_references.json?query[letter]=%`
    config.middleware.use TradeTariffFrontend::FilterBadURLEncoding
    config.middleware.use TradeTariffFrontend::BasicAuth do |username, password|
      username == TradeTariffFrontend.basic_username &&
        password == TradeTariffFrontend.basic_password
    end

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
