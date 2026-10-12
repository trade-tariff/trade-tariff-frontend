module GuidedSearch
  class QueuedSearchToken
    PURPOSE = 'queued-guided-search'.freeze

    def self.issue(id:, search_key:, session_id:, content_key:)
      verifier.generate(
        { 'id' => id,
          'search_key' => search_key,
          'content_key' => content_key,
          'session' => session_digest(session_id),
          'service' => TradeTariffFrontend::ServiceChooser.service_name.to_s },
        purpose: PURPOSE, expires_in: 1.hour,
      )
    end

    def self.search_key(token, id:, session_id:)
      verified_payload(token, id:, session_id:)&.dig('search_key')
    end

    def self.content_key(token, id:, session_id:)
      verified_payload(token, id:, session_id:)&.dig('content_key')
    end

    def self.verified_payload(token, id:, session_id:)
      return unless token.is_a?(String) && id.is_a?(String) && session_id.present?

      payload = verifier.verified(token, purpose: PURPOSE)
      return unless payload.is_a?(Hash) && payload['id'] == id
      return unless payload['service'] == TradeTariffFrontend::ServiceChooser.service_name.to_s
      return unless payload['session'].is_a?(String) &&
        ActiveSupport::SecurityUtils.secure_compare(payload['session'], session_digest(session_id))

      payload
    end
    private_class_method :verified_payload

    def self.verifier
      Rails.application.message_verifier(PURPOSE)
    end
    private_class_method :verifier

    def self.session_digest(session_id)
      Digest::SHA256.hexdigest(session_id)
    end
    private_class_method :session_digest
  end
end
