module TradeTariffFrontend
  # Thin wrapper around LaunchDarkly for feature flag evaluation.
  #
  # All flags must be declared in REGISTRY with a safe default. The default is
  # returned whenever LaunchDarkly is unreachable (offline mode, network error,
  # or test environment without a configured SDK key).
  #
  # Usage:
  #   TradeTariffFrontend::FeatureFlag.enabled?(:green_lanes)   # => true/false
  #   TradeTariffFrontend::FeatureFlag.disabled?(:green_lanes)  # => false/true
  #
  # In controllers and views (via FeatureFlaggable concern):
  #   feature_enabled?(:green_lanes)
  #   feature_disabled?(:green_lanes)
  #   before_action { require_feature!(:green_lanes) }
  #
  # In tests (via FeatureFlagHelpers):
  #   stub_feature_flag(:green_lanes, enabled: true)
  module FeatureFlag
    # Declare every feature flag here with its safe default value.
    # The default is used when LaunchDarkly is offline or unreachable.
    # Conventions:
    #   - Use snake_case symbols matching the LaunchDarkly flag key.
    #   - Default to false (off) unless the feature is safe to expose everywhere.
    REGISTRY = {
      green_lanes: false,
      interactive_search: false,
      roo_wizard: false,
      single_trade_window: false,
      webchat: false,
      welsh: false,
    }.freeze

    class UnknownFlagError < StandardError
      def initialize(flag)
        super(
          "Unknown feature flag: #{flag.inspect}. " \
          'Register it in TradeTariffFrontend::FeatureFlag::REGISTRY before use.',
        )
      end
    end

    # Returns true when the named flag is enabled in LaunchDarkly.
    # Falls back to the REGISTRY default when LD is offline or unavailable.
    # Raises UnknownFlagError for flag names not in REGISTRY (catches typos early).
    #
    # Pass user_key to enable percentage-based rollouts. LaunchDarkly hashes the
    # key into a bucket so the same visitor consistently sees the same result.
    # The FeatureFlaggable concern supplies this automatically from the session;
    # callers outside a request context can omit it (application context only).
    def self.enabled?(flag, user_key: nil)
      flag = flag.to_sym
      raise UnknownFlagError, flag unless REGISTRY.key?(flag)

      client.variation(flag.to_s, evaluation_context(user_key:), REGISTRY[flag])
    end

    def self.disabled?(flag, user_key: nil)
      !enabled?(flag, user_key:)
    end

    private_class_method def self.client
      Rails.application.config.launch_darkly_client
    end

    # Builds the LaunchDarkly evaluation context for a flag check.
    #
    # Always includes an application context carrying service (uk/xi) and
    # environment, so targeting rules can scope flags to specific deployments
    # without encoding that logic into flag names.
    #
    # When user_key is present a second anonymous user context is added, forming
    # a multi-context. LaunchDarkly uses the user key to hash visitors into
    # percentage buckets, enabling consistent gradual rollouts to a fraction of
    # real users. The key carries no PII — it is an anonymous UUID generated
    # once per session by the FeatureFlaggable concern.
    #
    # Rebuilt per-call because service_choice is thread-local (set per request).
    private_class_method def self.evaluation_context(user_key: nil)
      app_context = LaunchDarkly::LDContext.create(
        kind: 'application',
        key: 'trade-tariff-frontend',
        service: TradeTariffFrontend::ServiceChooser.service_choice&.to_s || 'uk',
        environment: TradeTariffFrontend.environment,
      )

      return app_context if user_key.nil?

      user_context = LaunchDarkly::LDContext.create(
        kind: 'user',
        key: user_key,
        anonymous: true,
      )

      LaunchDarkly::LDContext.create_multi([app_context, user_context])
    end
  end
end
