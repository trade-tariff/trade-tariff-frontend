module GuidedSearch
  class ImageDescriptionToken
    PURPOSE = 'guided-search-image-description'.freeze

    def self.issue(id:, session_id:)
      verifier.generate(
        { 'id' => id,
          'session' => Digest::SHA256.hexdigest(session_id),
          'service' => TradeTariffFrontend::ServiceChooser.service_name.to_s },
        purpose: PURPOSE, expires_in: 5.minutes,
      )
    end

    def self.valid?(token, id:, session_id:)
      return false unless token.is_a?(String) && id.is_a?(String) && session_id.present?

      payload = verifier.verified(token, purpose: PURPOSE)
      payload.is_a?(Hash) && payload['id'] == id &&
        payload['service'] == TradeTariffFrontend::ServiceChooser.service_name.to_s &&
        payload['session'].is_a?(String) &&
        ActiveSupport::SecurityUtils.secure_compare(payload['session'], Digest::SHA256.hexdigest(session_id))
    end

    def self.verifier
      Rails.application.message_verifier(PURPOSE)
    end
    private_class_method :verifier
  end
end
