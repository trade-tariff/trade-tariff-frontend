# Configure FlagsmithClient with credentials from environment variables.
#
# FLAGSMITH_ENVIRONMENT_KEY — SDK key for the self-hosted environment.
#   Used by the flagsmith gem to evaluate flags and read identity flags.
# FLAGSMITH_API_URL — base URL of the self-hosted FlagSmith instance,
#   e.g. https://flagsmith.example.com/api/v1/
# FLAGSMITH_ADMIN_API_KEY — server-side key with write access, used for
#   per-identity flag overrides and the anonymous→authenticated migration.
#
# In the test environment the singleton is replaced by a TestFlagsmithClient
# double (see spec/support/flagsmith.rb) so these env vars are not required there.
#
# Guarded on FLAGSMITH_ENVIRONMENT_KEY so environments without credentials
# (CI asset precompilation, test) boot cleanly without raising.
#
# Wrapped in to_prepare so the autoloaded FlagsmithClient constant resolves
# correctly: initializers run before eager loading, and referencing an app/
# constant at the top level here raises NameError during asset precompilation.
if ENV['FLAGSMITH_ENVIRONMENT_KEY'].present?
  Rails.application.config.to_prepare do
    FlagsmithClient.configure(
      environment_key: ENV.fetch('FLAGSMITH_ENVIRONMENT_KEY'),
      api_url: ENV.fetch('FLAGSMITH_API_URL'),
      admin_api_key: ENV.fetch('FLAGSMITH_ADMIN_API_KEY'),
    )
  end
end
