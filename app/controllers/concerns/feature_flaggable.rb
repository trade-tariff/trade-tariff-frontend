module FeatureFlaggable
  extend ActiveSupport::Concern

  included do
    helper_method :feature_enabled?, :feature_disabled?
  end

  # Returns true when the named flag is enabled. Available in views.
  #
  # Example:
  #   <% if feature_enabled?(:green_lanes) %>
  def feature_enabled?(flag)
    TradeTariffFrontend::FeatureFlag.enabled?(flag)
  end

  # Returns true when the named flag is disabled. Available in views.
  def feature_disabled?(flag)
    TradeTariffFrontend::FeatureFlag.disabled?(flag)
  end

  # Raises FeatureUnavailable when the named flag is disabled.
  # Use in before_action to gate controller actions behind a feature flag.
  #
  # Example:
  #   before_action { require_feature!(:green_lanes) }
  def require_feature!(flag)
    raise TradeTariffFrontend::FeatureUnavailable unless feature_enabled?(flag)
  end
end
