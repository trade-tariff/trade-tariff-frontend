sdk_key = ENV.fetch('LAUNCHDARKLY_SDK_KEY', '')

config = LaunchDarkly::Config.new(
  offline: sdk_key.blank?,
  logger: Rails.logger,
  log_level: Logger::WARN,
)

client = LaunchDarkly::LDClient.new(sdk_key, config)

unless client.initialized?
  Rails.logger.warn('LaunchDarkly client did not initialize in time; flag evaluations will use REGISTRY defaults')
end

Rails.application.config.launch_darkly_client = client

at_exit { Rails.application.config.launch_darkly_client&.close }
