require 'paas_config'

module TradeTariffFrontend
  autoload :Presenter,      'trade_tariff_frontend/presenter'
  autoload :ViewContext,    'trade_tariff_frontend/view_context'
  autoload :ServiceChooser, 'trade_tariff_frontend/service_chooser'

  module_function

  # API Endpoints of the Tariff Backend API app that can be reached via Frontend
  def accessible_api_endpoints
    %w[
      chapters
      commodities
      geographical_areas
      goods_nomenclatures
      headings
      monetary_exchange_rates
      quotas
      search_references
      sections
      subheadings
      updates
    ]
  end

  # API Endpoints of the Tariff Backend API app that can be reached via external client
  def public_api_endpoints
    %w[
      additional_code_types
      additional_codes
      certificate_types
      certificates
      changes
      chapters
      chemicals
      commodities
      footnote_types
      footnotes
      geographical_areas
      goods_nomenclatures
      headings
      healthcheck
      monetary_exchange_rates
      measure_types
      quotas
      rules_of_origin_schemes
      search
      search_references
      sections
      subheading
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

  def news_items_enabled?
    ENV['NEWS_ITEMS_ENABLED'].to_s == 'true'
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
