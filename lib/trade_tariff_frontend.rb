require 'paas_config'

module TradeTariffFrontend
  autoload :BasicAuth,      'trade_tariff_frontend/basic_auth'
  autoload :Presenter,      'trade_tariff_frontend/presenter'
  autoload :ServiceChooser, 'trade_tariff_frontend/service_chooser'
  autoload :ViewContext,    'trade_tariff_frontend/view_context'

  module_function

  # API Endpoints of the Tariff Backend API app that can be reached via Frontend
  def accessible_api_endpoints
    %w[
      sections
      chapters
      headings
      subheadings
      commodities
      updates
      monetary_exchange_rates
      quotas
      goods_nomenclatures
      search_references
      geographical_areas
    ]
  end

  # API Endpoints of the Tariff Backend API app that can be reached via external client
  def public_api_endpoints
    %w[
      sections
      chapters
      headings
      subheadings
      commodities
      monetary_exchange_rates
      quotas
      goods_nomenclatures
      search_references
      search
      additional_codes
      certificates
      footnotes
      geographical_areas
      chemicals
      additional_code_types
      certificate_types
      footnote_types
      changes
      rules_of_origin_schemes
      measure_types
      measure_condition_codes
      measure_actions
      quota_order_numbers
      healthcheck
    ]
  end

  def production?
    ENV['GOVUK_APP_DOMAIN'] == 'tariff-frontend-production.london.cloudapps.digital'
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

  def currency_default
    currency_default_gbp? ? 'GBP' : 'EUR'
  end

  def host
    ENV.fetch('FRONTEND_HOST', 'http://localhost')
  end

  def single_trade_window_url
    ENV.fetch(
      'STW_URI',
      'https://check-how-to-import-export-goods.service.gov.uk/manage-this-trade/check-licences-certificates-and-other-restrictions',
    )
  end

  def js_sentry_dsn
    ENV.fetch('JS_SENTRY_DSN', '')
  end

  def revision
    `cat REVISION 2>/dev/null || git rev-parse --short HEAD`.strip
  end

  def self.check_duties_service_url
    ENV.fetch('CHECK_DUTIES_SERVICE_URL', 'https://www.check-duties-customs-exporting-goods.service.gov.uk')
  end

  def search_banner?
    ENV['SEARCH_BANNER'].to_s == 'true'
  end

  def permutations?
    ENV['PERMUTATIONS'].to_s == 'true'
  end

  def welsh?
    ENV['WELSH'].to_s == 'true'
  end

  def roo_wizard?
    ENV['ROO_WIZARD'] == 'true'
  end

  def basic_auth?
    ENV['BASIC_AUTH'].to_s == 'true'
  end

  def basic_username
    ENV['BASIC_USERNAME'].to_s
  end

  def basic_password
    ENV['BASIC_PASSWORD'].to_s
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
end
