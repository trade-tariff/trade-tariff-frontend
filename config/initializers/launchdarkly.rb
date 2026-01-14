
if ENV.fetch('LAUNCHDARKLY_API_KEY', nil).present?
  Rails.configuration.ld_client = LaunchDarkly::LDClient.new(ENV['LAUNCHDARKLY_API_KEY'])
end
