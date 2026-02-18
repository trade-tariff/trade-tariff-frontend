module TradeTariffFrontend
  autoload :Presenter,      'trade_tariff_frontend/presenter'
  autoload :ServiceChooser, 'trade_tariff_frontend/service_chooser'
  autoload :ViewContext,    'trade_tariff_frontend/view_context'

  module_function

  def production?
    environment == 'production'
  end

  def environment
    ENV.fetch('ENVIRONMENT', 'production')
  end

  def id_token_cookie_name
    cookie_name_for('id_token')
  end

  def refresh_token_cookie_name
    cookie_name_for('refresh_token')
  end

  def cookie_name_for(base_name)
    case environment
    when 'production'
      base_name
    else
      "#{environment}_#{base_name}"
    end.to_sym
  end

  def redis_config
    { url: ENV['REDIS_URL'], db: 0, id: nil }
  end

  # Number of suggestions returned to select2
  def suggestions_count
    10
  end

  # Email of the user who receives all info/error notifications, feedback
  def from_email
    ENV['TARIFF_FROM_EMAIL']
  end

  def to_email
    ENV['TARIFF_TO_EMAIL']
  end

  def support_email
    ENV['TARIFF_SUPPORT_EMAIL']
  end

  def currency_default
    currency_default_gbp? ? 'GBP' : 'EUR'
  end

  def host
    ENV.fetch('FRONTEND_HOST', 'http://localhost')
  end

  def identity_base_url
    ENV.fetch('IDENTITY_BASE_URL', 'http://localhost:3005')
  end

  def identity_cookie_domain
    @identity_cookie_domain ||= if Rails.env.production?
                                  ".#{base_domain}"
                                else
                                  :all
                                end
  end

  def base_domain
    @base_domain ||= begin
      domain = ENV['GOVUK_APP_DOMAIN']

      unless /(http(s?):).*/.match(domain)
        domain = "https://#{domain}"
      end

      URI.parse(domain).host
    end
  end

  def backend_base_domain
    ENV['BACKEND_BASE_DOMAIN']
  end

  def single_trade_window_url
    ENV.fetch(
      'STW_URI',
      'https://check-how-to-import-export-goods.service.gov.uk/import/check-licences-certificates-and-other-restrictions',
    )
  end

  def single_trade_window_linking_enabled?
    ENV.fetch('STW_ENABLED', 'false') == 'true'
  end

  def revision
    @revision ||= `cat REVISION 2>/dev/null || echo 'development'`.strip
  end

  def self.check_duties_service_url
    ENV.fetch('CHECK_DUTIES_SERVICE_URL', 'https://www.check-duties-customs-exporting-goods.service.gov.uk')
  end

  def welsh?
    ENV['WELSH'].to_s == 'true'
  end

  def roo_wizard?
    ENV['ROO_WIZARD'] == 'true' && TradeTariffFrontend::ServiceChooser.uk?
  end

  def basic_auth?
    ENV['BASIC_AUTH'].to_s == 'true'
  end

  def webchat_enabled?
    webchat_url.present?
  end

  def webchat_url
    ENV['WEBCHAT_URL']
  end

  def legacy_results_to_show
    ENV.fetch('LEGACY_RESULTS_TO_SHOW', '5').to_i
  end

  def green_lanes_enabled?
    ENV['GREEN_LANES_ENABLED'].to_s == 'true'
  end

  def interactive_search_enabled?
    !production?
  end

  def green_lanes_api_token
    "Bearer #{ENV['GREEN_LANES_API_TOKEN']}"
  end

  def google_tag_manager_container_id
    ENV.fetch('GOOGLE_TAG_MANAGER_CONTAINER_ID', '')
  end

  def basic_session_authentication?
    @basic_session_authentication ||= basic_session_password.present?
  end

  def basic_session_password
    @basic_session_password ||= ENV['BASIC_PASSWORD']
  end

  class FilterBadURLEncoding
    def initialize(app)
      @app = app
    end

    def call(env)
      @query_string = env['QUERY_STRING'].to_s
      @path_string = env['PATH_INFO'].to_s
      begin
        Rack::Utils.parse_nested_query @query_string
        return bad_request unless @path_string.ascii_only? && @query_string.ascii_only?
      rescue Rack::Utils::InvalidParameterError
        return bad_request
      end

      @app.call(env)
    end

    def bad_request
      @status = 400
      [
        @status,
        { 'Content-Type' => 'application/json' },
        error_object,
      ]
    end

    def error_object
      [
        {
          errors: [
            {
              status: @status.to_s,
              title: 'There was a problem with your query',
              source: { parameter: 'Invalid query string' },
            },
          ],
        }.to_json,
      ]
    end
  end

  class FeatureUnavailable < StandardError; end
  class MaintenanceMode < StandardError; end
end
