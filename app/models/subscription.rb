class Subscription
  include AuthenticatableApiEntity

  set_singular_path '/uk/user/subscriptions/:id'

  attr_accessor :active, :uuid, :meta, :subscription_type

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

  def subscription_type_name
    subscription_type&.[]('name')
  end
end
