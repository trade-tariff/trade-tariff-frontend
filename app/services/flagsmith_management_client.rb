# Thin wrapper for writing identity traits directly to the Flagsmith core API.
#
# Uses the SDK trait endpoint (POST /api/v1/traits/) with the X-Environment-Key
# header — identical schema to the standard SDK, but sent to the Flagsmith core
# server via Cloud Map (http://flagsmith.tariff.internal:8000) rather than the
# Edge Proxy. The Edge Proxy is read-through and does not persist trait writes.
#
# Only set_trait is implemented — the read path uses the existing FlagsmithClient.
class FlagsmithManagementClient
  CORE_API_URL = 'http://flagsmith.tariff.internal:8000'.freeze

  class << self
    def instance
      @instance || raise('FlagsmithManagementClient not configured')
    end

    attr_writer :instance

    def configured?
      @instance.present?
    end

    def configure(environment_key:)
      @instance = new(environment_key:)
    end
  end

  def initialize(environment_key:)
    @connection = Faraday.new(url: CORE_API_URL) do |f|
      f.request :json
      f.response :raise_error
      f.response :json
      f.options.timeout = 2
      f.headers['X-Environment-Key'] = environment_key
    end
  end

  # Set a trait on the given Flagsmith identity.
  # trait_value should be a boolean, string, integer, or float.
  # Raises Faraday::Error on non-2xx responses.
  def set_trait(identifier, trait_key, trait_value)
    @connection.post('/api/v1/traits/', {
      identity: { identifier: identifier },
      trait_key: trait_key.to_s,
      trait_value: trait_value,
    })
  end
end
