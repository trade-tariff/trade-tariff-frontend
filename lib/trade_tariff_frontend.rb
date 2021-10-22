require 'paas_config'

module TradeTariffFrontend
  autoload :Presenter,      'trade_tariff_frontend/presenter'
  autoload :ViewContext,    'trade_tariff_frontend/view_context'
  autoload :ServiceChooser, 'trade_tariff_frontend/service_chooser'

  module_function

  # API Endpoints of the Tariff Backend API app that can be reached via Frontend
  def accessible_api_endpoints
    %w[
      sections
      chapters
      headings
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

  def currency_picker_enabled?
    ENV['CURRENCY_PICKER'].to_i == 1
  end

  def currency_default
    currency_default_gbp? ? 'GBP' : 'EUR'
  end

  def host
    ENV.fetch('FRONTEND_HOST', 'http://localhost')
  end

  def js_sentry_dsn
    ENV.fetch('JS_SENTRY_DSN', '')
  end

  def revision
    `cat REVISION 2>/dev/null || git rev-parse --short HEAD`.strip
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
              source: { parameter: @query_string },
            },
          ],
        }.to_json,
      ]
    end
  end
end
