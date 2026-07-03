# Wrapper for the Flagsmith core API — writes identity traits and reads
# identity flags directly from the core server.
#
# Both reads and writes use the SDK endpoints with the X-Environment-Key header,
# sent to the Flagsmith core server via Cloud Map
# (http://flagsmith.tariff.internal:8000) rather than the Edge Proxy.
# The Edge Proxy is read-through and does not persist trait writes, so reading
# back via the Edge Proxy after a write can show stale state.
class FlagsmithManagementClient
  CORE_API_URL = 'http://flagsmith.tariff.internal:8000'.freeze

  # Minimal flag wrapper returned by get_flags_for.
  class Flag
    def initialize(enabled:)
      @enabled = enabled
    end

    def enabled?
      @enabled
    end
  end

  # Wraps the flags array from POST /api/v1/identities/ with a get_flag interface.
  class Flags
    def initialize(flags_data)
      @by_name = flags_data.index_by { |f| f.dig('feature', 'name') }
    end

    def get_flag(name)
      data = @by_name[name.to_s]
      Flag.new(enabled: data ? data.fetch('enabled', false) : false)
    end
  end

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

  # Read identity flags from core so the state is consistent with trait writes.
  # Raises Faraday::Error on non-2xx responses.
  def get_flags_for(identity)
    response = @connection.post('/api/v1/identities/', {
      identifier: identity.identifier,
      traits: [],
    })
    Flags.new(response.body.fetch('flags', []))
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
