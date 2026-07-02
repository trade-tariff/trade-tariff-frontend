# Singleton wrapper around the Flagsmith SDK client.
#
# Evaluation (get_flags_for) uses the SDK environment key to call the
# Flagsmith API and returns a Flagsmith::Flags::Collection.
#
# When Flagsmith is not configured (no FLAGSMITH_ENVIRONMENT_KEY), configured?
# returns false and FlagsmithBackedConfig falls back to each flag's own
# Ruby-computed default rather than attempting an API call.
#
# In tests, FlagsmithClient.instance is replaced with a TestFlagsmithClient
# double (see spec/support/flagsmith.rb). Use FlagsmithClient.instance= to
# inject any replacement.
class FlagsmithClient
  class << self
    def instance
      @instance || raise('FlagsmithClient not configured - call FlagsmithClient.configure first or set instance= in tests')
    end

    def configured?
      !@instance.nil?
    end

    attr_writer :instance

    def configure(environment_key:, api_url:)
      @instance = new(environment_key:, api_url:)
    end
  end

  def initialize(environment_key:, api_url:)
    @environment_key = environment_key
    @api_url = api_url.to_s.delete_suffix('/')
    @sdk_client = Flagsmith::Client.new(
      environment_key: @environment_key,
      api_url: "#{@api_url}/",
      request_timeout_seconds: 1,
      # Return a disabled default flag rather than raising for unknown features.
      default_flag_handler: ->(_name) { Flagsmith::Flags::DefaultFlag.new(enabled: false, value: nil) },
    )
  end

  # Returns a Flagsmith::Flags::Collection for the given identity.
  # Call is_feature_enabled('flag_name') or get_feature_value('flag_name') on the result.
  # Unknown flags return false (via default_flag_handler) rather than raising.
  def get_flags_for(identity)
    @sdk_client.get_identity_flags(identity.identifier)
  end
end
