# Thin wrapper around the Flagsmith Management API for writing identity traits.
#
# Uses the admin identity-trait endpoint which requires:
#   FLAGSMITH_MANAGEMENT_API_TOKEN - a personal or service API token from the
#     Flagsmith dashboard. Distinct from the SDK environment key.
#
# Connects directly to the Flagsmith core API server (Cloud Map:
# http://flagsmith.tariff.internal:8000) rather than the Edge Proxy, because
# the Edge Proxy is read-only and does not persist trait writes.
#
# Only set_trait is implemented — the read path uses the existing FlagsmithClient.
class FlagsmithManagementClient
  MANAGEMENT_API_URL = 'http://flagsmith.tariff.internal:8000'.freeze

  class << self
    def instance
      @instance || raise('FlagsmithManagementClient not configured — set FLAGSMITH_MANAGEMENT_API_TOKEN')
    end

    attr_writer :instance

    def configured?
      @instance.present?
    end

    def configure(environment_key:, api_token:)
      @instance = new(environment_key:, api_token:)
    end
  end

  def initialize(environment_key:, api_token:)
    @environment_key = environment_key
    @connection = Faraday.new(url: MANAGEMENT_API_URL) do |f|
      f.request :json
      f.response :raise_error
      f.response :json
      f.options.timeout = 2
      f.headers['Authorization'] = "Api-Key #{api_token}"
    end
  end

  # Set a trait on the given Flagsmith identity.
  # trait_value should be a boolean, string, integer, or float.
  # Raises Faraday::Error on non-2xx responses.
  def set_trait(identifier, trait_key, trait_value)
    @connection.post("/api/v1/environments/#{@environment_key}/traits/", {
      identity: { identifier: identifier },
      trait_key: trait_key.to_s,
      trait_value: trait_value,
    })
  end
end
