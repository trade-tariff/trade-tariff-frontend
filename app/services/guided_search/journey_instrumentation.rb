module GuidedSearch
  class JourneyInstrumentation
    EVENT_NAME = 'guided_search.journey'.freeze
    SCHEMA_VERSION = 1

    class << self
      def record(**attributes)
        payload = { schema_version: SCHEMA_VERSION, **attributes }.compact

        ActiveSupport::Notifications.instrument(EVENT_NAME, payload)
        Rails.logger.info({ event: EVENT_NAME, **payload }.to_json)
      end

      def browser_session_id(raw_id)
        digest = OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secret_key_base, raw_id)
        "v1:#{digest}"
      end
    end
  end
end
