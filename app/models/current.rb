class Current < ActiveSupport::CurrentAttributes
  # The resolved Flagsmith identity for the current request.
  # Set by ApplicationController#set_current_flagsmith_identity.
  attribute :flagsmith_identity

  # The memoised flags collection returned by FlagsmithClient#get_flags_for.
  # Populated on first call to feature_enabled? and reused for the request lifetime.
  attribute :flagsmith_flags
end
