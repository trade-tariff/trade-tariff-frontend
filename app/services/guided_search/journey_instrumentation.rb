module GuidedSearch
  class JourneyInstrumentation
    EVENT_NAME = 'guided_search.journey'.freeze
    SCHEMA_VERSION = 1

    class << self
      def record(**attributes)
        payload = { schema_version: SCHEMA_VERSION, **attributes }.compact
        payload[:service] = TradeTariffFrontend::ServiceChooser.service_name.to_s
        payload[:search_scope] = 'guided'

        ActiveSupport::Notifications.instrument(EVENT_NAME, payload)
        Rails.logger.info({ event: EVENT_NAME, **payload }.to_json)
      end

      def browser_session_id(raw_id)
        digest = OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secret_key_base, raw_id)
        "v1:#{digest}"
      end

      def question_id(request_id:, question_number:, question:, options:)
        return if request_id.blank? || question.blank?

        Digest::SHA256.hexdigest(MultiJson.dump([
          request_id.to_s,
          question_number.to_i,
          question.to_s,
          Array(options).map(&:to_s),
        ]))
      end
    end
  end
end
