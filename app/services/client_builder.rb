class ClientBuilder
  DEFAULT_VERSION = '2'.freeze
  DEFAULT_FORMAT = 'jsonapi'.freeze

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

  def initialize(service, forwarding: false)
    @service = service
    @forwarding = forwarding
  end

  def call
    return nil if TradeTariffFrontend::ServiceChooser.service_choices.blank?

    return forwarding_client if @forwarding

    resource_client
  end

  private

  def forwarding_client
    Faraday.new(host) do |conn|
      conn.adapter :net_http_persistent
    end
  end

  def resource_client
    Faraday.new(host) do |conn|
      conn.request :url_encoded
      conn.request :retry, RETRY_DEFAULTS.merge(Rails.configuration.x.http.retry_options)
      conn.response :raise_error
      conn.adapter :net_http_persistent
      conn.response :json, content_type: /\bjson$/
      conn.headers['Accept'] = "application/vnd.uktt.v#{DEFAULT_VERSION}"
    end
  end

  def host
    TradeTariffFrontend::ServiceChooser.public_send("#{@service}_host")
  end
end
