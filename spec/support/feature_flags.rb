module FeatureFlagHelpers
  # Stubs a specific feature flag for the duration of an example.
  # Other flags continue to delegate to the real implementation.
  #
  # Examples:
  #   stub_feature_flag(:green_lanes, enabled: true)
  #   stub_feature_flag(:welsh)                      # enabled: true is the default
  #   stub_feature_flag(:roo_wizard, enabled: false)
  def stub_feature_flag(flag, enabled: true)
    # Only stub the named flag. Calls for any other flag are not intercepted and
    # fall through to the real implementation (which returns REGISTRY defaults in
    # offline mode), so multiple stub_feature_flag calls in one example compose cleanly.
    allow(TradeTariffFrontend::FeatureFlag).to receive(:enabled?).with(flag.to_sym, any_args).and_return(enabled)
  end
end

RSpec.configure do |config|
  config.include FeatureFlagHelpers
end
