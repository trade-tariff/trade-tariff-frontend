class ClientBuilder
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

  def initialize(service, cache: Rails.cache)
    @service = service
    @cache = cache
  end

  def call
    if TradeTariffFrontend::ServiceChooser.service_choices.present?
      Faraday.new(host) do |conn|
        conn.request :url_encoded
        conn.request :retry, RETRY_DEFAULTS.merge(Rails.configuration.x.http.retry_options)
        conn.response :raise_error
        conn.adapter :net_http_persistent
        conn.response :json, content_type: /\bjson$/
      end
    end
  end

  private

  def host
    TradeTariffFrontend::ServiceChooser.public_send("#{@service}_host")
  end
end
