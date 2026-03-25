module DutyCalculator
  class ClientBuilder
    ACCEPT = 'application/vnd.hmrc.2.0+json'.freeze

    RETRY_DEFAULTS = {
      methods: %i[get head],
      max: 1,
      interval: 0.5,
      interval_randomness: 0.5,
      backoff_factor: 2,
      exceptions: (
        Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS +
        Faraday::Error.descendants -
        [
          # ClientError is needed because the following three inherit from it and
          # ClientError is in Error's descendants list
          Faraday::ClientError,
          Faraday::ResourceNotFound,
          Faraday::ForbiddenError,
          Faraday::UnauthorizedError,
        ]
      ),
    }.freeze

    def initialize(service)
      @service = service
    end

    def call
      Uktt::Http.new(connection, host:)
    end

  private

    def connection
      cert_path = '/tmp/backend.crt'
      File.write(cert_path, ENV['SSL_CERT_PEM']&.gsub('\\n', "\n"))

      Faraday.new(url: host) do |faraday|
        faraday.use Faraday::Response::RaiseError
        faraday.use Faraday::FollowRedirects::Middleware
        faraday.response :logger if ENV['DEBUG_REQUESTS']
        faraday.request :retry, RETRY_DEFAULTS.merge(Rails.configuration.x.http.retry_options)
        faraday.ssl.verify = false
        faraday.ssl.ca_file = cert_path
        faraday.adapter :net_http_persistent

        faraday.headers['User-Agent'] = user_agent
        faraday.headers['Accept'] = ACCEPT
      end
    end

    def host
      Rails.application.config.api_options[@service]
    end

    def user_agent
      @user_agent ||= "TradeTariffFrontend/#{TradeTariffFrontend.revision}"
    end
  end
end
