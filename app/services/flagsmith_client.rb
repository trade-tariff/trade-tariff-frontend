# Singleton wrapper around the Flagsmith SDK client.
#
# Evaluation (get_flags_for) uses the SDK environment key to call the
# Flagsmith API and returns a Flagsmith::Flags::Collection.
#
# In tests, FlagsmithClient.instance is replaced with a TestFlagsmithClient
# double (see spec/support/flagsmith.rb). Use FlagsmithClient.instance= to
# inject any replacement.
class FlagsmithClient
  class SdkLogger
    def initialize(logger)
      @logger = logger
    end

    def debug(*) = nil

    def info(*) = nil

    def warn(message = nil, &block)
      @logger.warn(message || block&.call)
    end

    def error(message = nil, &block)
      @logger.error(message || block&.call)
    end

    def fatal(message = nil, &block)
      @logger.fatal(message || block&.call)
    end
  end

  class << self
    def instance
      @instance || raise('FlagsmithClient not configured - call FlagsmithClient.configure first or set instance= in tests')
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
      logger: SdkLogger.new(Rails.logger),
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
