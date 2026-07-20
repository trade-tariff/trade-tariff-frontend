class Current < ActiveSupport::CurrentAttributes
  # The resolved Flagsmith identity for the current request.
  # Set by ApplicationController#set_current_flagsmith_identity.
  attribute :flagsmith_identity

  # The memoised flags collection returned by FlagsmithClient#get_flags_for.
  # Reused for the request lifetime once feature flags have been fetched.
  attribute :flagsmith_flags

  # Set when Flagsmith cannot be reached/configured during the current request.
  attribute :flagsmith_unavailable

  # Opt-in trait overrides for the current request (keyed by flag name, boolean or SDK trait options).
  # Loaded from session by FlagsmithSetup and passed through to Edge Proxy evaluation.
  attribute :flagsmith_optin_traits

  # Instrumentation label for the most recently enrolled active experiment.
  attribute :experiment
end
