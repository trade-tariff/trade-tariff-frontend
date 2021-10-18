class ClientBuilder
  DEFAULT_VERSION = '2'.freeze
  DEFAULT_FORMAT = 'jsonapi'.freeze

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
      conn.adapter :net_http_persistent
      conn.response :json, content_type: /\bjson$/
      conn.headers['Accept'] = "application/vnd.uktt.v#{DEFAULT_VERSION}"
    end
  end

  def host
    TradeTariffFrontend::ServiceChooser.public_send("#{@service}_host")
  end
end
