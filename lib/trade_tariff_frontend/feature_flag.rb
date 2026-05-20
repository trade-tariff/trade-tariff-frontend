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
    def self.enabled?(flag)
      flag = flag.to_sym
      raise UnknownFlagError, flag unless REGISTRY.key?(flag)

      client.variation(flag.to_s, evaluation_context, REGISTRY[flag])
    end

    def self.disabled?(flag)
      !enabled?(flag)
    end

    private_class_method def self.client
      Rails.application.config.launch_darkly_client
    end

    # Application-level context sent to LaunchDarkly with each flag evaluation.
    # Includes service (uk/xi) and environment as custom attributes so LD targeting
    # rules can target specific environments or service variants without encoding
    # that logic into flag names.
    #
    # This is rebuilt per-call because service_choice is thread-local (set per request).
    private_class_method def self.evaluation_context
      LaunchDarkly::LDContext.create(
        kind: 'application',
        key: 'trade-tariff-frontend',
        service: TradeTariffFrontend::ServiceChooser.service_choice&.to_s || 'uk',
        environment: TradeTariffFrontend.environment,
      )
    end
  end
end
