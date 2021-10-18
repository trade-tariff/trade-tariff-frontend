class ClientBuilder
  DEFAULT_VERSION = '2'.freeze
  DEFAULT_FORMAT = 'jsonapi'.freeze

  def initialize(service, forwarding: false)
    @service = service
    @forwarding = forwarding
  end

  def call
    return nil if TradeTariffFrontend::ServiceChooser.service_choices.blank?
    return Faraday.new(host) if @forwarding

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
