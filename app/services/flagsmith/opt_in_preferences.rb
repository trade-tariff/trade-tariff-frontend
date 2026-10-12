module Flagsmith
  # Core owns saved preferences. This identity-bound cookie supplies them to Edge
  # without a core lookup on ordinary requests or a dependency on the Rails session.
  class OptInPreferences
    COOKIE_NAME = :flagsmith_optin_preferences
    SESSION_KEY = :flagsmith_optin_traits

    def self.names
      TradeTariffFrontend::Config.registered_flags.values.select { |flag| flag[:optin] }.pluck(:name)
    end

    def self.filter(traits)
      return {} unless traits.is_a?(Hash)

      traits.transform_keys(&:to_s).slice(*names).select { |_name, value| [true, false].include?(value) }
    end

    def initialize(cookies:, session:, identity:, migrate_session:)
      @cookies = cookies
      @session = session
      @identity = identity
      @migrate_session = migrate_session
    end

    def read
      return @preferences if defined?(@preferences)

      stored = @cookies.signed[COOKIE_NAME]
      @preferences = matching_cookie?(stored) ? self.class.filter(stored['preferences']) : {}
      return @preferences unless @session.key?(SESSION_KEY)

      # An old session must not overwrite a newer cookie or follow a changed identity.
      legacy = if @migrate_session && (stored.nil? || matching_cookie?(stored))
                 self.class.filter(@session[SESSION_KEY])
               else
                 {}
               end
      write(legacy.merge(@preferences))
    end

    def write(preferences)
      preferences = self.class.filter(preferences)
      options = { expires: 1.year.from_now, httponly: true, secure: Rails.env.production?, same_site: :lax }
      @cookies.signed[COOKIE_NAME] = options.merge(value: {
        identity: @identity.identifier,
        environment: TradeTariffFrontend.environment,
        preferences:,
      })
      # Renew both expiries together, without changing the UUID used for rollouts.
      @cookies[:flagsmith_anonymous_id] = options.merge(value: @cookies[:flagsmith_anonymous_id])
      @session.delete(SESSION_KEY)
      @preferences = preferences
    end

    private

    def matching_cookie?(stored)
      stored.is_a?(Hash) && stored['identity'] == @identity.identifier &&
        stored['environment'] == TradeTariffFrontend.environment
    end
  end
end
