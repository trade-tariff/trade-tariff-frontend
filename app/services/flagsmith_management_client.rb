# Thin wrapper around the Flagsmith Management API for writing identity traits.
#
# The Management API requires a separate token (FLAGSMITH_MANAGEMENT_API_TOKEN)
# distinct from the environment SDK key used by FlagsmithClient.
#
# Only set_trait is implemented — the read path uses the existing FlagsmithClient.
class FlagsmithManagementClient
  class << self
    def instance
      @instance || raise('FlagsmithManagementClient not configured — set FLAGSMITH_MANAGEMENT_API_TOKEN')
    end

    attr_writer :instance

    def configured?
      @instance.present?
    end

    def configure(api_url:, api_token:)
      @instance = new(api_url:, api_token:)
    end
  end

  def initialize(api_url:, api_token:)
    @connection = Faraday.new(url: api_url.to_s.delete_suffix('/')) do |f|
      f.request :json
      f.response :json
      f.options.timeout = 2
      f.headers['Authorization'] = "Token #{api_token}"
    end
  end

  # Set a trait on the given Flagsmith identity.
  # trait_value should be a boolean, string, integer, or float.
  def set_trait(identifier, trait_key, trait_value)
    @connection.post('/api/v1/traits/', {
      identity: { identifier: identifier },
      trait_key: trait_key.to_s,
      trait_value: trait_value,
    })
  end
end
