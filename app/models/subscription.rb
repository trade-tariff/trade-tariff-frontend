class Subscription
  include AuthenticatableApiEntity

  set_singular_path '/uk/user/subscriptions/:id'

  attr_accessor :active, :uuid, :meta

  def self.batch(token, attributes)
    return nil if token.nil? && !Rails.env.development?

    json_api_params = {
      data: {
        attributes: attributes,
      },
    }
    super(json_api_params, headers(token))
  rescue Faraday::UnauthorizedError
    nil
  end

  def self.headers(token)
    {
      authorization: "Bearer #{token}",
    }
  end
end
