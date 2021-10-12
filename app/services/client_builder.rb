class ClientBuilder
  DEFAULT_VERSION = 'v2'.freeze
  DEFAULT_FORMAT = 'jsonapi'.freeze

  def initialize(service)
    @service = service
  end

  def call
    Faraday.new(host) do |conn|
      conn.request :url_encoded
      conn.adapter Faraday.default_adapter
      conn.response :json, content_type: /\bjson$/
      conn.headers['Accept'] = "application/vnd.uktt.v#{DEFAULT_VERSION}"
    end
  end

  private

  def host
    TradeTariffFrontend::ServiceChooser.public_send("#{@service}_host")
  end
end
