module AuthenticatableApiEntity
  extend ActiveSupport::Concern
  include UkOnlyApiEntity

  module ClassMethods
    def find(id, token, options = {})
      return nil if token.nil? && !Rails.env.development?

      super(id, options, headers(token))
    rescue Faraday::UnauthorizedError
      nil
    end

    def all(token, params = {})
      if token.nil? && !Rails.env.development?
        return []
      end

      collection(collection_path, params, headers(token))
    rescue Faraday::UnauthorizedError
      []
    end

    def headers(token)
      {
        authorization: "Bearer #{token}",
      }
    end
  end
end
