class Current < ActiveSupport::CurrentAttributes
  # The CloudFront-derived country for the current request.
  # Normalised for StringInquirer predicates such as Current.request_country.gb?.
  attribute :request_country, default: -> { ActiveSupport::StringInquirer.new('') }

  # The resolved Flagsmith identity for the current request.
  # Set by ApplicationController#set_current_flagsmith_identity.
  attribute :flagsmith_identity

  # The memoised flags collection returned by FlagsmithClient#get_flags_for.
  # Reused for the request lifetime once feature flags have been fetched.
  attribute :flagsmith_flags

  # Actual decisions and their sources, without identity or trait values.
  attribute :flagsmith_evaluations, default: -> { {} }

  # Set when Flagsmith cannot be reached/configured during the current request.
  attribute :flagsmith_unavailable

  # Persisted manual preferences and any lookup failure, cached for one request.
  attribute :flagsmith_preferences, :flagsmith_preference_error

  # Transient country and experiment traits supplied to Edge evaluation.
  attribute :flagsmith_request_traits

  # Instrumentation label for the most recently enrolled active experiment URL,
  # or `tenpct` when Flagsmith selected interactive search and no URL enrolment is active.
  attribute :experiment

  # Path of the most recently enrolled active experiment URL.
  attribute :experiment_url
end
