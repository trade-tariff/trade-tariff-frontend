module AuthenticatableApiEntity
  extend ActiveSupport::Concern
  include UkOnlyApiEntity

  module ClassMethods
    def find(id, token)
      return nil if token.nil? && !Rails.env.development?

      super(id, {}, headers(token))
    rescue Faraday::UnauthorizedError
      nil
    end

    def headers(token)
      {
        authorization: "Bearer #{token}",
      }
    end
  end
end
