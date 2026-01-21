class FeatureService
  class << self
    def is_enabled?(feature, session_identifier, default: false)
      context = LaunchDarkly::LDContext.create({ # rubocop:disable Rails/SaveBang
        key: session_identifier.to_s,
        kind: 'user',
      })

      Rails.configuration.ld_client.variation(feature, context, default)
    end
  end
end
