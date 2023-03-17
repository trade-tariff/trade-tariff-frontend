require 'paas_config'

module TradeTariffFrontend
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
      measures
      measure_types
      measure_condition_codes
      measure_actions
      quota_order_numbers
      preference_codes
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
      'https://check-how-to-import-export-goods.service.gov.uk/import/check-licences-certificates-and-other-restrictions',
    )
  end

  def single_trade_window_linking_enabled?
    ENV.fetch('STW_ENABLED', 'false') == 'true'
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

  def welsh?
    ENV['WELSH'].to_s == 'true'
  end

  def roo_wizard?
    ENV['ROO_WIZARD'] == 'true' && TradeTariffFrontend::ServiceChooser.uk?
  end

  def webchat_enabled?
    webchat_url.present?
  end

  def webchat_url
    ENV['WEBCHAT_URL']
  end

  def search_banner?
    ENV['SEARCH_BANNER'] == 'true'
  end

  def beta_search_switching_enabled?
    ENV['BETA_SEARCH_SWITCHING_ENABLED'] == 'true'
  end

  def beta_search_heading_statistics_threshold
    ENV['BETA_SEARCH_HEADING_STATISTICS_THRESHOLD'].to_i
  end

  def beta_search_facet_filter_display_percentage_threshold
    ENV['BETA_SEARCH_FACET_FILTER_DISPLAY_PERCENTAGE_THRESHOLD'].to_i
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
