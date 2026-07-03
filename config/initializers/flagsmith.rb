# Configure Flagsmith clients with credentials from environment variables.
#
# FLAGSMITH_ENVIRONMENT_KEY - SDK key for the self-hosted environment.
#   Used by the flagsmith gem to evaluate flags and read identity flags.
#   Also used by FlagsmithManagementClient to write identity traits via
#   the Flagsmith core API (Cloud Map internal URL, not Edge Proxy).
# FLAGSMITH_API_URL - optional override for the self-hosted FlagSmith
#   instance. Defaults to the Flagsmith Edge URL for
#   TradeTariffFrontend.environment.
#
# In the test environment the singletons are replaced by test doubles
# (see spec/support/flagsmith.rb) so these env vars are not required there.
#
# Guarded on FLAGSMITH_ENVIRONMENT_KEY and api_url so environments without
# credentials (CI asset precompilation, test, ad-hoc review apps) boot cleanly
# with guided search disabled.
#
# Wrapped in to_prepare so the autoloaded constants resolve correctly:
# initializers run before eager loading, and referencing an app/ constant at
# the top level here raises NameError during asset precompilation.
flagsmith_environment_key = ENV['FLAGSMITH_ENVIRONMENT_KEY']
flagsmith_api_url = TradeTariffFrontend.flagsmith_api_url

if flagsmith_environment_key.present? && flagsmith_api_url.present?
  Rails.application.config.to_prepare do
    FlagsmithClient.configure(
      environment_key: flagsmith_environment_key,
      api_url: flagsmith_api_url,
    )

    FlagsmithManagementClient.configure(
      environment_key: flagsmith_environment_key,
    )
  end
elsif flagsmith_environment_key.blank?
  Rails.logger.warn('Flagsmith environment key is not configured; feature flags will use their per-flag defaults')
else
  Rails.logger.warn("Flagsmith API URL is not configured for ENVIRONMENT=#{TradeTariffFrontend.environment}; guided search is disabled")
end
