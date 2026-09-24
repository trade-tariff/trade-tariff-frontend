module TradeTariffFrontend
  class RequestCountryMiddleware < Faraday::Middleware
    HEADER = 'X-Request-Country'.freeze

    def on_request(env)
      env.request_headers[HEADER] = Current.request_country.presence&.to_s || 'unknown'
    end
  end
end
