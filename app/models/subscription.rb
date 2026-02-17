class Subscription
  include AuthenticatableApiEntity

  set_singular_path '/uk/user/subscriptions/:id'

  has_one :subscription_type, class_name: 'SubscriptionType'

  attr_accessor :active, :uuid, :meta

  def self.batch(id, token, attributes)
    return nil if token.nil? && !Rails.env.development?

    json_api_params = {
      data: {
        attributes: attributes,
      },
    }
    super(id, json_api_params, headers(token))
  rescue Faraday::UnauthorizedError
    nil
  end
end
