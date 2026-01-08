module AuthenticatableApiEntity
  extend ActiveSupport::Concern
  include UkOnlyApiEntity

  module ClassMethods
    def find(id, token, options = {})
      return nil if token.nil? && !Rails.env.development?

      super(id, options, headers(token))
    rescue Faraday::UnauthorizedError => e
      handle_unauthorized_error(e)
    end

    def all(token, params = {})
      if token.nil? && !Rails.env.development?
        return []
      end

      collection(collection_path, params, headers(token))
    rescue Faraday::UnauthorizedError => e
      handle_unauthorized_error(e, default_return: [])
    end

    def headers(token)
      {
        authorization: "Bearer #{token}",
      }
    end

  private

    def handle_unauthorized_error(error, default_return: nil)
      reason = extract_error_reason(error)

      if reason
        raise AuthenticationError.new(error.message, reason:)
      else
        default_return
      end
    end

    def extract_error_reason(error)
      return nil unless error.response&.dig(:body)

      body = JSON.parse(error.response[:body])
      body.dig('errors', 0, 'code')
    rescue JSON::ParserError
      nil
    end
  end
end
