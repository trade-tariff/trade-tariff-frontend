module FeatureHelper

  def feature_enabled?(feature, default: false)
    context = LaunchDarkly::LDContext.with_key(session_identifier) # rubocop:disable Rails/SaveBang

    Rails.configuration.ld_client.variation(feature, context, default)
  end

end
