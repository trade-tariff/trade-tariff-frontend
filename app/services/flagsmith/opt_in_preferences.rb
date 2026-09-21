module Flagsmith
  # Core owns manual preferences; Edge evaluates them alongside request traits.
  # Cache only for this request, including failures, so flags share one lookup.
  class OptInPreferences
    def self.current
      raise Current.flagsmith_preference_error if Current.flagsmith_preference_error
      return Current.flagsmith_preferences unless Current.flagsmith_preferences.nil?

      names = TradeTariffFrontend::Config.registered_flags.values.select { |flag| flag[:optin] }.pluck(:name)
      traits = FlagsmithManagementClient.instance.get_traits_for(Current.flagsmith_identity)
      Current.flagsmith_preferences = traits.slice(*names).select { |_name, value| [true, false].include?(value) }
    rescue StandardError => e
      Current.flagsmith_preference_error = e
      raise
    end
  end
end
