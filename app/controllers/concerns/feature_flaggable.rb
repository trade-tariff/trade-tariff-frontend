module FeatureFlaggable
  extend ActiveSupport::Concern

  included do
    helper_method :feature_enabled?, :feature_disabled?
  end

  module ClassMethods
    # Declares that this controller (or specific actions) requires a feature flag
    # to be enabled. Sets up a before_action that raises FeatureUnavailable when
    # the flag is off. Accepts the same options as before_action.
    #
    # Examples:
    #   class GreenLanesController < ApplicationController
    #     feature_gate :green_lanes
    #   end
    #
    #   class MyController < ApplicationController
    #     feature_gate :my_feature, only: :new_action
    #   end
    def feature_gate(flag, **options)
      before_action(**options) { require_feature!(flag) }
    end
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
  # Use directly in a before_action block, or prefer the feature_gate class macro.
  def require_feature!(flag)
    raise TradeTariffFrontend::FeatureUnavailable unless feature_enabled?(flag)
  end
end
