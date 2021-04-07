require 'rails'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Requires an encryption key in `ENV["RAILS_MASTER_KEY"]` or
  # `config/secrets.yml.key`.
  config.read_encrypted_secrets = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.public_file_server.enabled = true

  config.public_file_server.headers = {
    'Cache-Control' => 'public, s-maxage=31536000, max-age=15552000',
    'Expires' => 1.year.from_now.to_formatted_s(:rfc822)
  }

  # Compress JavaScripts and CSS
  # config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Don't fallback to assets pipeline if a precompiled asset is missed
  # config.assets.compile = false


  # Rather than use a CSS compressor, use the SASS style to perform compression.
  # config.sass.style = :compressed
  # config.sass.line_comments = false


  config.webpacker.check_yarn_integrity = false

  # Generate digests for assets URLs
  # config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # See everything in the log (default is :info)
  config.log_level = :info

  config.logger = ActiveSupport::Logger.new($stdout)
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Logstash.new
  config.lograge.custom_options = lambda do |event|
    {
      params: event.payload[:params].except('controller', 'action', 'format', 'utf8'),
    }.merge(
      JSON.parse(ENV['VCAP_APPLICATION']).except('application_uris', 'host', 'application_name', 'space_id', 'port', 'uris', 'application_version')
    )
  end
  config.lograge.ignore_actions = ['HealthcheckController#index']

  # Rails cache store
  # PaasConfig.redis returns url and db
  config.cache_store = :redis_store, PaasConfig.redis.merge({
    expires_in: 1.day,
    namespace:  ENV['GOVUK_APP_DOMAIN'],
    pool_size:  Integer(ENV['MAX_THREADS'] || 5)
  })

  # set default_url_options
  config.action_controller.default_url_options = {
    host: ENV['HOST'] || 'www.trade-tariff.service.gov.uk'
  }

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :ses

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
end
