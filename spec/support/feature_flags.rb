module FeatureFlagHelpers
  # Stubs a specific feature flag for the duration of an example.
  # Other flags continue to delegate to the real implementation.
  #
  # Examples:
  #   stub_feature_flag(:green_lanes, enabled: true)
  #   stub_feature_flag(:welsh)                      # enabled: true is the default
  #   stub_feature_flag(:roo_wizard, enabled: false)
  def stub_feature_flag(flag, enabled: true)
    allow(TradeTariffFrontend::FeatureFlag).to receive(:enabled?).and_call_original
    allow(TradeTariffFrontend::FeatureFlag).to receive(:enabled?).with(flag.to_sym).and_return(enabled)
  end
end

RSpec.configure do |config|
  config.include FeatureFlagHelpers
end
