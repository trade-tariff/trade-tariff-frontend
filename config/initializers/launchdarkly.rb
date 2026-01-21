if ENV.fetch('LAUNCHDARKLY_API_KEY', nil).present?
  LaunchDarkly::Config.new({
    application: {
      id: 'trade-tariff-frontend',
    },
  })
  Rails.configuration.ld_client = LaunchDarkly::LDClient.new(ENV['LAUNCHDARKLY_API_KEY'])
end
